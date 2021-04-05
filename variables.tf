variable "name" {
    description = "Name of the git repository and kustomization objects"
}

variable "values" {

}

variable "namespace" {

}

variable "create_namespace" {
    default = true
}

variable "gitrepository" {

}

variable "branch" {
    default = "main"
}

variable "path" {
    default = "./chart"
}



variable "git_token" {
    default = ""
}

variable "git_user" {
    default = ""
}