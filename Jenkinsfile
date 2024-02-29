pipline { 
    agent any
     
    stages {
      stage("checkout scm") {
        steps {
          git branch: 'main', url: 'https://github.com/prateekkumawat/terraform_jenkins.git'
        }
      }

      stage("terraform Init"){
        steps { 
            sh 'terraform init'
        }
      }

      stage("terrafoem plan"){
        steps {
            sh 'terraform plan'
        }
      } 

      stage("terraform apply") { 
        steps { 
            sh 'terraform apply --auto-approve'
        }
      }
    }
}