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
        sh "aws s3 sync s3://elife-test-fixtures/strip-coverletter /ext/cached-repositories/strip-coverletter-test-fixtures"
        elifeLocalTests './project_tests.sh /ext/cached-repositories/strip-coverletter-test-fixtures'
    }

    elifeMainlineOnly {
        stage 'Push image', {
            image.push()
            image.tag('latest').push()
        }
    }
}
