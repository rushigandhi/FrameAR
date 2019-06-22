package com.asdev.frame

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.annotation.AsyncConfigurer
import org.springframework.scheduling.annotation.EnableAsync
import java.util.concurrent.Executor
import java.util.concurrent.Executors

@Configuration
@EnableAsync
class AsyncConfig: AsyncConfigurer {

	override fun getAsyncExecutor(): Executor? {
		return Executors.newFixedThreadPool(16)
	}
}

@EnableAsync
@SpringBootApplication
class FrameApplication

fun main(args: Array<String>) {
	runApplication<FrameApplication>(*args)
}
