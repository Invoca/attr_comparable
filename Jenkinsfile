#!/usr/bin/groovy
@Library('jenkins-pipeline@v0.4.4')
import com.invoca.docker.*;

pipeline {
  agent { 
    kubernetes {
      defaultContainer 'ruby'
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins/attr-comparable: true
  namespace: jenkins
  name: attr-comparable
spec:
  containers:
  - name: ruby
    image: ruby:2.6.1
    tty: true
    command:
    - cat
'''
    }
  }
  stages {
    stage('Unit Tests') {
      environment { 
        GITHUB_KEY = credentials('github_key') 
      }

      steps {
        script {
          sh '''
            # get SSH setup inside the container
            eval `ssh-agent -s`
            echo "$GITHUB_KEY" | ssh-add -
            mkdir -p /root/.ssh
            ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

            # run tests
            bundle install --path vendor/bundle
            bundle exec rake test
          '''
        }
      }

      post {
        always { junit 'test/reports/*.xml' }
      }
    }
  }

  post { always { notifySlack(currentBuild.result) } }
}
