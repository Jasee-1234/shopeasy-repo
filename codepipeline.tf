# =============================================================================
# codepipeline.tf — Source → Parallel Build → Parallel Deploy
# =============================================================================

resource "aws_codestarconnections_connection" "github" {
  name          = "${local.name_prefix}-github"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "main" {
  name     = "${local.name_prefix}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build_Product"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["product_build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.product.name
      }
    }

    action {
      name             = "Build_Order"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["order_build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.order.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy_Product"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["product_build_output"]

      configuration = {
        ApplicationName                = aws_codedeploy_app.product.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.product.deployment_group_name
        TaskDefinitionTemplateArtifact = "product_build_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "product_build_output"
        AppSpecTemplatePath            = "appspec.yml"
        Image1ArtifactName             = "product_build_output"
        Image1ContainerName            = "product"
      }
    }

    action {
      name            = "Deploy_Order"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["order_build_output"]

      configuration = {
        ApplicationName                = aws_codedeploy_app.order.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.order.deployment_group_name
        TaskDefinitionTemplateArtifact = "order_build_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "order_build_output"
        AppSpecTemplatePath            = "appspec.yml"
        Image1ArtifactName             = "order_build_output"
        Image1ContainerName            = "order"
      }
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pipeline"
  })
}