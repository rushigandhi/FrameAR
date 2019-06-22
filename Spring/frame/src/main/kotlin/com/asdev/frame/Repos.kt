package com.asdev.frame

import org.springframework.data.mongodb.repository.MongoRepository

interface ProjectsRepo: MongoRepository<Project, String> {

    fun findAllByOrderByLastEditTimeDesc(): List<Project>?
}