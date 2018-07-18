elifeLibrary {
    def commit
    def DockerImage image

    stage 'Checkout', {
        checkout scm
        commit = elifeGitRevision()
    }

    stage 'Build image', {
        sh "IMAGE_TAG=${commit} ./build-image.sh"
        image = DockerImage.elifesciences(this, "strip-coverletter", commit)
    }

    stage 'Run tests', {
        elifeLocalTests './project_tests.sh'
    }

    elifeMainlineOnly {
        stage 'Push image', {
            image.push()
        }
    }
}
