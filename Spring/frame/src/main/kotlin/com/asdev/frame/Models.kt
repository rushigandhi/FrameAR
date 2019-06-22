package com.asdev.frame

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import java.util.*

data class Tag(
        var name: String
)

data class Commit(
        var id: String = UUID.randomUUID().toString(),
        var message: String,
        var tags: MutableList<Tag>,
        var parentId: String? = null,
        var branchingName: String? = null
)

@Document(collection = "projects")
data class Project(
        @Id
        var id: String? = null,
        var name: String,
        var description: String?,
        var autoCommit: Boolean,
        var commits: MutableList<Commit>
)