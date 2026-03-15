package com.bilal.sticcker

import android.content.ContentProvider
import android.content.ContentValues
import android.content.UriMatcher
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.File

class StickerContentProvider : ContentProvider() {

    companion object {
        private const val TAG = "StickerProvider"
        private const val METADATA = 1
        private const val METADATA_CODE = 2
        private const val STICKERS = 3
        private const val STICKER_FILE = 4
        private const val STICKER_TRAY = 5

        private lateinit var AUTHORITY: String
        private lateinit var uriMatcher: UriMatcher
    }

    private val stickerDir: File
        get() = File(context!!.filesDir, "sticker_packs")

    override fun onCreate(): Boolean {
        AUTHORITY = "${context!!.packageName}.stickercontentprovider"
        uriMatcher = UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(AUTHORITY, "metadata", METADATA)
            addURI(AUTHORITY, "metadata/*", METADATA_CODE)
            addURI(AUTHORITY, "stickers/*", STICKERS)
            addURI(AUTHORITY, "stickers_asset/*/*", STICKER_FILE)
        }
        Log.d(TAG, "ContentProvider created with authority: $AUTHORITY")
        return true
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor? {
        Log.d(TAG, "query: $uri")

        if (!stickerDir.exists()) {
            Log.e(TAG, "Sticker directory does not exist: ${stickerDir.absolutePath}")
            return null
        }

        return when (uriMatcher.match(uri)) {
            METADATA -> {
                Log.d(TAG, "Returning all packs metadata")
                getPackListCursor()
            }
            METADATA_CODE -> {
                val packId = uri.lastPathSegment ?: return null
                Log.d(TAG, "Returning metadata for pack: $packId")
                getPackCursor(packId)
            }
            STICKERS -> {
                val packId = uri.lastPathSegment ?: return null
                Log.d(TAG, "Returning stickers for pack: $packId")
                getStickersCursor(packId)
            }
            else -> {
                Log.w(TAG, "Unknown URI: $uri (match=${uriMatcher.match(uri)})")
                null
            }
        }
    }

    private fun getPackListCursor(): Cursor {
        val cursor = MatrixCursor(arrayOf(
            "sticker_pack_identifier",
            "sticker_pack_name",
            "sticker_pack_publisher",
            "sticker_pack_icon",
            "android_play_store_link",
            "ios_app_store_link",
            "publisher_email",
            "publisher_website",
            "privacy_policy_website",
            "license_agreement_website",
            "image_data_version",
            "avoid_cache",
            "animated_sticker_pack"
        ))

        stickerDir.listFiles()?.filter { it.isDirectory }?.forEach { packDir ->
            addPackRow(cursor, packDir)
        }

        Log.d(TAG, "Pack list cursor has ${cursor.count} rows")
        return cursor
    }

    private fun getPackCursor(packId: String): Cursor {
        val cursor = MatrixCursor(arrayOf(
            "sticker_pack_identifier",
            "sticker_pack_name",
            "sticker_pack_publisher",
            "sticker_pack_icon",
            "android_play_store_link",
            "ios_app_store_link",
            "publisher_email",
            "publisher_website",
            "privacy_policy_website",
            "license_agreement_website",
            "image_data_version",
            "avoid_cache",
            "animated_sticker_pack"
        ))

        val packDir = File(stickerDir, packId)
        if (packDir.exists()) {
            addPackRow(cursor, packDir)
        }
        return cursor
    }

    private fun addPackRow(cursor: MatrixCursor, packDir: File) {
        val configFile = File(packDir, "config.txt")
        if (!configFile.exists()) return

        val lines = configFile.readLines()
        val name = lines.getOrNull(0) ?: packDir.name
        val author = lines.getOrNull(1) ?: "Sticcker"
        val isAnimated = lines.getOrNull(2) == "1"
        val version = lines.getOrNull(3) ?: "1"

        Log.d(TAG, "Pack ${packDir.name}: name=$name, animated=$isAnimated, version=$version")

        cursor.addRow(arrayOf(
            packDir.name,       // identifier
            name,               // name
            author,             // publisher
            "tray.webp",        // icon file name
            "",                 // play store link
            "",                 // app store link
            "",                 // publisher email
            "",                 // publisher website
            "",                 // privacy policy
            "",                 // license agreement
            version,            // image_data_version — changes on each export
            "0",                // avoid_cache
            if (isAnimated) "1" else "0"  // animated
        ))
    }

    private fun getStickersCursor(packId: String): Cursor {
        val cursor = MatrixCursor(arrayOf(
            "sticker_file_name",
            "sticker_emoji"
        ))

        val packDir = File(stickerDir, packId)
        if (!packDir.exists()) {
            Log.e(TAG, "Pack directory not found: ${packDir.absolutePath}")
            return cursor
        }

        val stickerFiles = packDir.listFiles()?.filter {
            it.name.endsWith(".webp") && it.name != "tray.webp" && it.name != "config.txt"
        }?.sortedBy { it.name }

        stickerFiles?.forEach { file ->
            Log.d(TAG, "Adding sticker: ${file.name} (${file.length()} bytes)")
            cursor.addRow(arrayOf(file.name, "\uD83D\uDE00"))
        }

        Log.d(TAG, "Stickers cursor has ${cursor.count} rows for pack $packId")
        return cursor
    }

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor? {
        Log.d(TAG, "openFile: $uri")

        val segments = uri.pathSegments
        // Expected: stickers_asset/<pack_id>/<file_name>
        if (segments.size >= 3 && segments[0] == "stickers_asset") {
            val packId = segments[1]
            val fileName = segments[2]
            val file = File(stickerDir, "$packId/$fileName")

            Log.d(TAG, "Opening file: ${file.absolutePath} (exists=${file.exists()}, size=${if(file.exists()) file.length() else 0})")

            if (file.exists()) {
                return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            } else {
                Log.e(TAG, "File not found: ${file.absolutePath}")
            }
        }
        return null
    }

    override fun getType(uri: Uri): String {
        return when (uriMatcher.match(uri)) {
            METADATA, METADATA_CODE -> "vnd.android.cursor.dir/vnd.$AUTHORITY.metadata"
            STICKERS -> "vnd.android.cursor.dir/vnd.$AUTHORITY.stickers"
            STICKER_FILE -> "image/webp"
            else -> "application/octet-stream"
        }
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}
