import * as pulumi from "@pulumi/pulumi";
import * as awsx from "@pulumi/awsx";
import * as aws from "@pulumi/aws";

const imageUrl = process.env.IMAGE_URL as string;

const repository = new awsx.ecr.Repository("aattri");

const listener = new awsx.elasticloadbalancingv2.NetworkListener("website-lb", {
  port: 80,
  targetGroup: {
    port: 3000,
  },
});

const service = new awsx.ecs.FargateService("nextjs-website", {
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
  waitForSteadyState: false,
});

export const frontendURL = pulumi.interpolate`http://${listener.endpoint.hostname}/`;
