// @flow

import * as React from "react";
import { createReactWrapper } from "utilities";
import {
  QuickStartContainer,
  useLocalStorage,
  QuickStartPanelContent,
  QuickStartContextProvider
} from "@patternfly/quickstarts";
// /dist/quickstarts-full.es
import { DrawerContext } from "@patternfly/react-core";

const explorePipelinesQuickStart = {
  metadata: {
    name: "explore-pipelines",
  },
  spec: {
    displayName: `Installing the Pipelines Operator`,
    icon: "",
    durationMinutes: 10,
    description: `Install the OpenShift® Pipelines Operator to build Pipelines using Tekton.`,
    introduction: `OpenShift® Pipelines is a cloud-native, continuous integration and continuous delivery (CI/CD) solution based on Kubernetes resources. It uses Tekton building blocks to automate deployments across multiple Kubernetes distributions by abstracting away the underlying implementation details.
  * OpenShift Pipelines is a serverless CI/CD system that runs pipelines with all the required dependencies in isolated containers.
  * They are designed for decentralized teams that work on a microservice-based architecture.
  * They are defined using standard Custom Resource Definitions making them extensible and easy to integrate with the existing Kubernetes tools. This enables you to scale on-demand.
  * You can use OpenShift Pipelines to build images with Kubernetes tools such as Source-to-Image (S2I), Buildah, Buildpacks, and Kaniko that are portable across any Kubernetes platform.
  * You can use the Developer perspective to create and manage pipelines and view logs in your namespaces.
  
  To start using Pipelines, install the OpenShift® Pipelines Operator on your cluster.`,
    tasks: [
      {
        title: `Installing the OpenShift Pipelines Operator`,
        description: `### To install the OpenShift Pipelines Operator:
  
  1. From the **Administrator** perspective in the console navigation panel, click **Operators > OperatorHub**.
  2. In the **Filter by keyword** field, type \`OpenShift Pipelines Operator\`.
  3. If the tile has an Installed label, the Operator is already installed. Proceed to the next quick start to create a Pipeline.
  4. Click the **tile** to open the Operator details.
  5. At the top of the OpenShift Pipelines Operator panel that opens, click **Install**.
  6. Fill out the Operator subscription form by selecting the channel that matches your OpenShift cluster, and then click **Install**.
  7. On the **Installed Operators** page, wait for the OpenShift Pipelines Operator's status to change from **Installing** to **Succeeded**. `,
        review: {
          instructions: `#### To verify that the OpenShift Pipelines Operator is installed:
  1. From the **Operators** section of the navigation, go to the **Installed Operators** page.
  2. Verify that the **OpenShift Pipelines Operator** appears in the list of Operators.
  
  In the status column, is the status of the OpenShift Pipelines Operator **Succeeded**?`,
          failedTaskHelp: `This task isn’t verified yet. Try the task again, or [read more](https://docs.openshift.com/container-platform/4.6/pipelines/installing-pipelines.html#op-installing-pipelines-operator-in-web-console_installing-pipelines) about this topic.`,
        },
        summary: {
          success: `You have installed the Pipelines Operator!`,
          failed: `Try the steps again.`,
        },
      },
    ],
    conclusion: `You successfully installed the OpenShift Pipelines Operator! If you want to learn how to deploy an application and associate a Pipeline with it, take the Creating a Pipeline quick start.`,
    nextQuickStart: [`install-app-and-associate-pipeline`],
  },
};

const QuickStartsDrawer = () => {
  const [quickStarts, setQuickStarts] = React.useState([
    explorePipelinesQuickStart,
  ]);
  //   const [loading, setLoading] = React.useState(true);
  const [activeQuickStartID, setActiveQuickStartID] = useLocalStorage(
    "quickstartId",
    "" // "explore-pipelines"
  );
  const [allQuickStartStates, setAllQuickStartStates] = useLocalStorage(
    "quickstarts",
    {}
  );

  const valuesForQuickstartContext = {
    allQuickStarts: quickStarts,
    activeQuickStartID,
    setActiveQuickStartID,
    allQuickStartStates,
    setAllQuickStartStates,
    footer: {
      show: true,
    },
    language: "en",
  };

  return <QuickStartPanelContent quickStarts={quickStarts} activeQuickStartID={activeQuickStartID} /*isResizable={null}*/ /*handleClose={() => {}}*/ />

  // return (
  //   <DrawerContext.Provider value={{ isExpanded: true/*, isStatic, onExpand, position, drawerRef*/ }}>
  //   <QuickStartContextProvider value={valuesForQuickstartContext}>
  //     <QuickStartPanelContent quickStarts={quickStarts} activeQuickStartID={activeQuickStartID} /*isResizable={null}*/ /*handleClose={() => {}}*/ />
  //   </QuickStartContextProvider>
  //   </DrawerContext.Provider>
  // );

  //   const drawerProps = {
  //     quickStarts,
  //     activeQuickStartID,
  //     allQuickStartStates,
  //     setActiveQuickStartID,
  //     setAllQuickStartStates,
  //     showCardFooters: false,
  //     loading: false,
  //     fullWidth: true
  //   }

  //   return <QuickStartContainer {...drawerProps} />
};

const QuickStartsDrawerWrapper = (props, containerId: string): void =>
  createReactWrapper(<QuickStartsDrawer {...props} />, containerId);

export { QuickStartsDrawer, QuickStartsDrawerWrapper };
