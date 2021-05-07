import * as pulumi from "@pulumi/pulumi";
import * as awsx from "@pulumi/awsx";

const imageUrl = process.env.IMAGE_URL as string;

const vpc = new awsx.ec2.Vpc("main", {
  cidrBlock: "10.0.0.0/16",
  // subnets: [{ name: "a", type: "private" }],
});

const cluster = new awsx.ecs.Cluster("main", { vpc }, { dependsOn: vpc });

const alb = new awsx.lb.ApplicationLoadBalancer("web-traffic", {
  vpc,
  securityGroups: cluster.securityGroups,
});

const repository = new awsx.ecr.Repository("aattri");

const listener = alb.createListener(
  "web-listener",
  {
    protocol: "HTTP",
    port: 80,
    targetGroup: {
      protocol: "HTTP",
      port: 3000,
    },
    vpc,
  },
  { dependsOn: vpc }
);

const service = new awsx.ecs.FargateService("nextjs-website", {
  cluster,
  desiredCount: 1,
  taskDefinitionArgs: {
    containers: {
      website: {
        image: imageUrl,
        memory: 512,
        portMappings: [listener],
      },
    },
  },
  subnets: vpc.privateSubnetIds,
  waitForSteadyState: false,
});

export const frontendURL = pulumi.interpolate`http://${listener.endpoint.hostname}/`;
