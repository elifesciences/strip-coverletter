elifeLibrary {
    stage 'Checkout', {
        checkout scm
    }

    stage 'Build image', {
        sh './build-image.sh'
    }

    stage 'Run tests', {
        elifeLocalTests './project_tests.sh'
    }
}
