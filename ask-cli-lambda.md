# Create an Alexa Skill Powered by AWS Lambda

<!-- TOC -->
- [Set Up the Toolkit](#set-up-the-toolkit)
    - [Install AWS Command Line Interface](#install-aws-command-line-interface)
    - [IAM Users and Policies](#iam-users-and-policies)
    - [Install and Configure Alexa Skills Kit CLI](#install-and-configure-alexa-skills-kit-cli)
- [Create an Alexa Skill](#create-an-alexa-skill)
- [Resources](#resources)
<!-- /TOC -->

## Set Up the Toolkit

Amazon provides a command line interface (CLI) tool for working with many of its services. For developing Alexa skills, you will need the Alexa Skills Kit (ASK) and Amazon AWS CLI if you choose to implent your intent handlers using AWS Lambda.

[AWS Lambda](https://aws.amazon.com/lambda/) is a [serveless computing](https://en.wikipedia.org/wiki/Serverless_computing) service that allows developers to deploy and run code on the web without needing to manage any server infrastructure. They can be implemented using a variety of programming languages including Node.js, Java, C#, Go and Python.

The ASK CLI provides a convenient utility to generate and create the artifacts for an Alexa skill:
> - Skills manifest
> - Interaction model
> - AWS Lambda

### Install AWS Command Line Interface

For this to work, you must first install and configure the [AWS CLI](https://aws.amazon.com/cli/). Download and follow the instructions based on your operating system requirements. Be sure to include the AWS CLI binaries in your OS PATH.

Test your AWS CLI installation:
```
$ aws configure
aws-cli/1.14.50 Python/2.7.14 Windows/10 botocore/1.9.3
```

### IAM Users and Policies

Next, head over the [AWS Console](https://aws.amazon.com/console/). You will need to:
> - Create an IAM policy for ASK to deploy AWS Lambda functions.
> - Create an IAM user and assign the ASK Lambda Deploy policy.

1. Click on any of the `Sign In to the Console` buttons.
2. Login using the "Root user" (the Amazon account used to sign up for AWS services).
3. Select the region `US East (N. Virginia)` using the drop-down menu on the top-right.
4. In the AWS service search box, type `IAM` and then select the `IAM` service.
5. Click the`Policies` item on the left navigation menu.
6. Click the`Create policy` button.
7. Click the `JSON` tab.
8. Copy the contents from the file [`resources/aws-lambda-deployer-iam-policy.json`](resources/aws-lambda-deployer-iam-policy.json) and paste into the text editor.
9. Click the `Review policy` button.
10. Enter the policy name, e.g. `AskLambdaDeployer`.
11. Click the 'Create policy'.
12. After the policy has been created successfully, click on the `Users` item on the left navigation menu.
13. Click the `Add user` button.
14. Enter a user name and select `Programmatic access` for `Access type`.
15. Click the `Next:Permissions` button.
16. Click the button `Attach existing policies directly` button.
17. Search for and select the IAM policy created in the earlier steps.
18. Click the `Next:Review` button.
19. Click the `Create user` button.
20. When the IAM user has been created successfully, the `Access key ID` and `Secret access key` will be displayed. Click the `Show` link to reveal the `Secret access key`. **IMPORTANT:** This code is displayed only once, so note it down!

Now you are ready to configure the AWS CLI:
```
$ aws configure
AWS Access Key ID [None]: ********************
AWS Secret Access Key [None]: ****************************************
Default region name [None]: us-east-1
Default output format [None]: json
```

### Install and Configure Alexa Skills Kit CLI
1. Download and install [Node.js](https://nodejs.org).
2. Install the ASK CLI:
```
$ sudo npm install -g ask-cli
```
3. Initialize the ASK CLI. During the initialization, select the default profile and associate an AWS credential. A browser session will be created for you to login, approve and automatically inject the token to the CLI.
```
$ ask init
-------------------- Initialize CLI --------------------
Setting up ask profile: [default]
? Please choose one from the following AWS profiles for skill's Lambda function deployment.
 default
Switch to 'Login with Amazon' page...
Tokens fetched and recorded in ask-cli config.
Vendor ID set as **************

Profile [default] initialized successfully.
```

## Create an Alexa Skill
Once both CLIs and accounts are set up correctly, the next thing to do is to create your first Alexa skill!
1. Use the ASK CLI to generate the artifacts:
```
$ ask new --skill-name GreeterBot --lambda-name greeter-bot-service
New project for Alexa skill created.
```
5. The following artifacts will be generated:

| Directories/Files | Description |
| - | - |
| `GreeterBot/` | Project directory for your Alexa Skill |
| `.ask/config` | Skill ID and AWS Lambda of the newly created stored here. |
| `lambda/` | A Node.js application that deploys to AWS Lambda. |
| `models/en-US.json` | Contains JSON-formatted [Intent Schema](https://developer.amazon.com/docs/custom-skills/define-the-interaction-model-in-json-and-text.html#h2_intents) files, one for each language/region. |
| `skill.json` | [Skill Manifest](https://developer.amazon.com/docs/smapi/skill-manifest.html) - JSON representation of the skill, containing all required metadata. |

6. Customize your skill. First, modify the `invocationName` attribute in the file `models/en-US.json`. This is the invocation name that is used to launch the skill, e.g. `greeter robot`.
7. Also, update the example phrases in the skills manifest (`skill.json`) and replace the phrase `hello world` with the invocation name specified in the interaction model.
8. Deploy the skill. This may take a while.
```
$ ask deploy
-------------------- Create Skill Project --------------------
Profile for the deployment: [default]
Skill Id: amzn1.ask.skill.3b9e6eec-b445-4e77-a441-202252f1c54d
Skill deployment finished.
Model deployment finished.
Lambda deployment finished.
```
9. Enable the skill:
```
$ ask api enable-skill -s amzn1.ask.skill.3b9e6eec-b445-4e77-a441-202252f1c54d
The skill has been enabled.
```
10. Test the skill:
```
$ ask simulate -t "Alexa open greeter robot" -l en-US
```

#### Additional Notes
* A typical deployment consist of all three phases. Note that you may choose to perform only one of these phases when deploying. See the [documentation](https://developer.amazon.com/docs/smapi/ask-cli-command-reference.html#deploy-command) on the `target` option for details.
* The test can also be tested using the [Alexa Console](https://developer.amazon.com/alexa/console/ask).


## Resources

* [ASK CLI Command Reference](https://developer.amazon.com/docs/smapi/ask-cli-command-reference.html)
* [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/)