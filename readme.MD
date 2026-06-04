#Terrafrom AWS VPC

1. I have created a two VPC's, one is main other one is default.
2. Created IGW with VPC associations
3. Created three subnets -- Public,private,database.
4. created three route tables for three subnets
5. Associated with routes.
6. Created EIP 
7. Created NAT gateway which is depended on IGW.
8. Connected two VPC's Using VPC peering, with condition to create or not
9. Made route table entires through peering.

#Inputs
Project - (required) User should pass the Project name, String type.
Enivornment - (required) User should pass the Env name, it should be Dev,UAT,QA.

#outputs
All the outputs should be given so that they can be used further reference in project.

