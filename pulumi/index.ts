import * as pulumi from "@pulumi/pulumi";
import * as awsx from "@pulumi/awsx";

// Create a load balancer to listen for requests and route them to the container.
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
        image: awsx.ecs.Image.fromPath("website", "../"),
        memory: 512,
        portMappings: [listener],
      },
    },
  },
});

export const frontendURL = pulumi.interpolate`http://${listener.endpoint.hostname}/`;
