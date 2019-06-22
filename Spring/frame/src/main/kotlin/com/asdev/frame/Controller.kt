package com.asdev.frame

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import java.io.File

@RestController
class Controller {

    @Autowired
    private lateinit var fileSystem: FileSystem

    @Autowired
    private lateinit var projectRepo: ProjectsRepo

    @RequestMapping("/project/init")
    fun initProject(@RequestParam("name", required = true) name: String, @RequestParam("desc", required = false) desc: String?): Project {
        val project = Project(null, name, desc, false, mutableListOf())
        projectRepo.save(project)
        return project
    }

    @RequestMapping("/project/get")
    fun getProject(@RequestParam("id", required = true) id: String): Project? {
        return projectRepo.findById(id).orElseGet { null }
    }

    @RequestMapping("/project/get_all")
    fun getProjects(): List<Project> {
        return projectRepo.findAll()
    }

    @RequestMapping("/project/{project_id}/commit")
    fun createCommit(@RequestParam("message") message: String, @PathVariable("project_id") projectId: String, @RequestParam("parent") parentId: String, @RequestParam("branching", required = false) branching: String?): Commit? {
        val p = projectRepo.findById(projectId)

        if(!p.isPresent) return null

        val project = p.get()

        val commit: Commit

        if(parentId == "INIT") {
            // the base commit
            commit = Commit(
                    message = message,
                    tags = mutableListOf(),
                    parentId = null,
                    branchingName = "master"
            )
        } else {
            commit = Commit(
                    message = message,
                    tags = mutableListOf(),
                    parentId = parentId,
                    branchingName = branching
            )
        }

        project.commits.add(commit)

        projectRepo.save(project)

        return commit
    }

    @RequestMapping("/project/{project_id}/tags/add/{commit_id}")
    fun addTag(@PathVariable("project_id") projectId: String, @PathVariable("commit_id") commitId: String, @RequestParam("name") name: String): Commit? {
        val p = projectRepo.findById(projectId)

        if(!p.isPresent) return null

        val project = p.get()

        val commit = project.commits.find { it.id == commitId }?: return null

        commit.tags.add(Tag(name))

        projectRepo.save(project)

        return commit
    }

    @RequestMapping("/project/{project_id}/process/{commit_id}")
    fun postProcess(@PathVariable("project_id") projectId: String, @PathVariable("commit_id") commitId: String): String {
        val p = projectRepo.findById(projectId)

        if(!p.isPresent) return "{ \"success\": false }"
        val project = p.get()
        val commit = project.commits.find { it.id == commitId }?: return "{ \"success\": false }"

        val folder = fileSystem.getCommitDir(project, commit)
        val hasProcessed = File(folder, ".processed").exists()

        if(hasProcessed) {
            return "{ \"success\": true }"
        }

        // TODO: begin conversion here

        return "{ \"success\": true }"
    }

    /**
     * REQUIRES EXISTING COMMIT TO WORK
     */
    @PostMapping("/project/{project_id}/upload/{commit_id}")
    fun uploadFile(@RequestParam("file") file: MultipartFile, @RequestParam("relative_path") path: String,
                   @PathVariable("project_id") projectId: String, @PathVariable("commit_id") commitId: String): String {

        val p = projectRepo.findById(projectId)

        if(!p.isPresent) return "{ \"success\": false }"
        val project = p.get()
        val commit = project.commits.find { it.id == commitId }?: return "{ \"success\": false }"

        val f = File(fileSystem.getCommitDir(project, commit))
        file.transferTo(f)

        return "{ \"success\": true }"
    }
}