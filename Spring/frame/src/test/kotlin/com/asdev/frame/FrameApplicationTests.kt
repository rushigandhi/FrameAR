package com.asdev.frame

import org.junit.Test
import org.junit.runner.RunWith
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.HttpMethod
import org.springframework.test.context.junit4.SpringRunner
import org.springframework.web.client.RequestCallback
import org.springframework.web.client.RestTemplate
import java.net.URL
import java.net.URLEncoder

@RunWith(SpringRunner::class)
@SpringBootTest
class FrameApplicationTests {

	private val messageUrl = "https://adichha.api.stdlib.com/http-project@dev/"

	@Test
	fun sendsMessage() {
		val template = RestTemplate()
		val encoded = URLEncoder.encode("{ \"project\": \"general\", \"text\": \"New commit 'Adi Gay', click <SOMETHING> to check it out.\" }", "UTF8")
		println("executing")
		val request = "$messageUrl?obj=$encoded"
		println(request)

		URL(request).openConnection().getInputStream().close()
//
//		template.getForEntity(request, String::class.java)

//		template.execute<String>(request, HttpMethod.GET, RequestCallback {
//			it.headers.add("User-Agent", "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Mobile Safari/537.36")
//			it.headers.add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3")
//			it.headers.add("Accept-Encoding", "gzip, deflate, br")
//			it.headers.add("Accept-Language", "en-CA,en-GB;q=0.9,en-US;q=0.8,en;q=0.7")
//			it.headers.add("Cache-Control", "no-cache")
//			it.headers.add("Connection", "keep-alive")
//			it.headers.add("Host", "adichha.api.stdlib.com")
//			it.headers.add("Pragma", "no-cache")
//			it.headers.add("Upgrade-Insecure-Requests", "1")
//		}, null)
	}

}
