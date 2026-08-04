# =============================================================================
# Microsoft Entra ID (Azure AD) SAML Federation
# Place the metadata XML file (downloaded from Azure Enterprise Application)
# next to this Terraform code and name it entra-id-metadata.xml
# =============================================================================
# You will upload the Entra ID metadata XML (or the IdP certificate + SSO URL)
# This creates the SAML provider that AWS trusts.

resource "aws_iam_saml_provider" "entra_id" {
  name                   = "${local.name_prefix}-entra-id-provider"
  saml_metadata_document = file("${path.root}/entra-id-metadata.xml")

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-entra-id-provider"
  })
}

resource "aws_iam_role" "entra_devops" {
  name = "${local.name_prefix}-entra-devops-engineer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_saml_provider.entra_id.arn
      }
      Action = "sts:AssumeRoleWithSAML"
      Condition = {
        StringEquals = {
          "SAML:aud" = "https://signin.aws.amazon.com/saml"
        }
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-entra-devops-engineer"
  })
}

resource "aws_iam_role_policy_attachment" "entra_devops" {
  role       = aws_iam_role.entra_devops.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "entra_readonly" {
  name = "${local.name_prefix}-entra-readonly-auditor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_saml_provider.entra_id.arn
      }
      Action = "sts:AssumeRoleWithSAML"
      Condition = {
        StringEquals = {
          "SAML:aud" = "https://signin.aws.amazon.com/saml"
        }
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-entra-readonly-auditor"
  })
}

resource "aws_iam_role_policy_attachment" "entra_readonly" {
  role       = aws_iam_role.entra_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
