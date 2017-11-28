elifeLibrary {
    stage 'Checkout', {
        checkout scm
    }

    stage 'Build image', {
        sh './build_image.sh'
    }

    stage 'Run tests', {
        elifeLocalTests './project_tests.sh'
    }
}
