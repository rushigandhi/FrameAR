package com.asdev.frame

import org.springframework.stereotype.Service

@Service
class FileSystem {

    private val basePath = "storage"

    fun getProjectDir(project: Project): String {
        return "$basePath/${project.id}"
    }

    fun getCommitDir(project: Project, commit: Commit): String {
        return "${getProjectDir(project)}/${commit.id}"
    }


}