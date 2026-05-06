package com.darkmatter.bookcut;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class BookcutApplication {

	public static void main(String[] args) {
		SpringApplication.run(BookcutApplication.class, args);
	}

}
