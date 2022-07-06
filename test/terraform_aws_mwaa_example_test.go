// Copyright © 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved. This AWS Content is provided subject to the terms of the AWS Customer Agreement available at http://aws.amazon.com/agreement or other written agreement between Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both."

package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/random"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsMwaaExample(t *testing.T) {
	t.Parallel()

	unavailableRegions := []string{"us-west-1"} // Regions where MWAA is not available: https://docs.aws.amazon.com/mwaa/latest/userguide/what-is-mwaa.html#regions-mwaa
	region := aws.GetRandomStableRegion(t, nil, unavailableRegions)
	uniqueId := random.UniqueId()

	// Create an S3 bucket where we can store state
	bucketName := fmt.Sprintf("test-terraform-backend-%s", strings.ToLower(uniqueId))
	defer cleanupS3Bucket(t, region, bucketName)
	aws.CreateS3Bucket(t, region, bucketName)

	key := fmt.Sprintf("%s/terraform.tfstate", uniqueId)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/mwaa/environment",
		Vars: map[string]interface{}{
			"region": region,
		},
		BackendConfig: map[string]interface{}{
			"bucket": bucketName,
			"key":    key,
			"region": region,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}

func cleanupS3Bucket(t *testing.T, awsRegion string, bucketName string) {
	aws.EmptyS3Bucket(t, awsRegion, bucketName)
	aws.DeleteS3Bucket(t, awsRegion, bucketName)
}
