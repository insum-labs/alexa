# Alexa

Help guide on Amazon Alexa for Hackathon 2018

<!-- TOC -->

- [Alexa](#alexa)
  - [About](#about)
  - [Setup](#setup)
    - [Alexa Developer Account](#alexa-developer-account)
    - [AWS Developer console](#aws-developer-console)
    - [Links](#links)
  - [Definitions](#definitions)

<!-- /TOC -->

## About

This guide will demonstrate how to get a `Hello World` example working with Alexa using multiple techniques. The focus of this guide is for Insum's internal Hackathon 2018 but can be used/leveraged for other purposes. This guide won't walk you through all the different options/posiblities of the Alexa API.

There are a lot of moving parts when working with Alexa and it can get confusing at times. Please always keep the following in perspective when developing for Alexa:

```
Users makes 
```

## Setup

### Alexa Developer Account

Go to [developer.amazon.com](https://developer.amazon.com/). Either use your existing Amazon account or create a new one (using your insum.ca address).

### AWS Developer console

Go to [AWS](aws.amazon.com/free) and click `Create a Free Account` 




### Links

Title | Description
--- | ---
[Alexa Developer Home](https://developer.amazon.com/alexa) | 
[Skills Console](https://developer.amazon.com/alexa/console/ask) | Build, manage, test skills

## Definitions

It's important to understand Alexa's terminology. Below is a brief overview of some key terminology. For a more complete overview read [this](https://medium.com/@screenmedia/utterances-slots-and-skills-the-new-vocabulary-needed-to-develop-for-voice-7428bff4ed79) article.

Term | Description | Example
--- | --- | ---
[Wake Word](https://www.amazon.com/gp/help/customer/display.html?nodeId=201971890) | What Alexa "listens to" before taking an action. In most cases it will be `Alexa` but can be configured to `Amazon` or `Echo`. | **Alexa** what time is it. In this example `Alexa` is the wake word.
Skill | "App" for Alexa | Complete list of Alexa skills [here](https://www.amazon.com/b?node=13727921011). Each one of them are skills.
[Invocation](https://developer.amazon.com/docs/custom-skills/choose-the-invocation-name-for-a-custom-skill.html) | Trigger word for skill | ["Alexa, ask CBC for help"](https://www.amazon.com/gp/product/B07743SCXC?ref=skillrw_dsk_pnps_dp_2) In this case the invocation is `CBC`. For custom skills invocations should be 2 or more words.
[Intent](https://developer.amazon.com/docs/custom-skills/use-the-skill-builder-beta-to-define-intents-slots-and-dialogs.html#intents-and-slots) | What user is requesting / function to perform | "Alexa what is the weather" - the intent is to find the weather
[Utterance](https://developer.amazon.com/docs/custom-skills/best-practices-for-sample-utterances-and-custom-slot-type-values.html) | What follows an invocation to determine intent | "Alexa, ask CBC for help". In this case `for help` would be the utterance. An intent can have multiple utterances.
Slot | TODO | TODO
