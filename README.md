## Explanation of `min` Calculation
var.count_num: This is the number of subnets you want to create, which you provide as input.
length(data.aws_availability_zones.available.names): This calculates the number of availability zones available in the selected AWS region.

## Inputs

var.region: AWS region (e.g., us-west-2)
var.count_num: Desired number of subnets (e.g., 10)

## Availability Zones:

Suppose data.aws_availability_zones.available.names returns ["us-west-2a", "us-west-2b", "us-west-2c"],
so there are 3 availability zones.

## Calculation:

var.count_num = 10
length(data.aws_availability_zones.available.names) = 3
effective_count_num = min(10, 3) = 3

Thus, effective_count_num will be 3.

## Explanation of `cider block` Calculation

## Explanation of `cidrsubnet` Function

### The cidrsubnet function in Terraform is used to calculate subnets from a given CIDR block

`syntax` : cidrsubnet(base, newbits, netnum)

