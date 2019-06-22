package com.asdev.frame

import org.springframework.scheduling.annotation.Async
import org.springframework.scheduling.annotation.EnableAsync
import org.springframework.stereotype.Service
import java.io.File
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

@Service
@EnableAsync
class ColladaConvertor {

    companion object {
        private const val SCRIPT_PATH = "./convert_dae"
    }

    @Async
    fun convert(file: File): CompletableFuture<Void> =
            CompletableFuture.runAsync {
                val path = file.absolutePath
                val destPath = path.substringBeforeLast('.') + ".scn"
                val builder = ProcessBuilder(SCRIPT_PATH, path, destPath)
                val process = builder.start()
                try {
                    process.waitFor(20, TimeUnit.SECONDS)
                } catch (e: Exception) {}
            }

}