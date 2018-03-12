# Create an Alexa Skill Powered by ORDS

<!-- TOC -->
- [Alexa Basic Toolkit](#alexa-basic-toolkit)
- [The REST Data Service](#the-rest-data-service)
- [Handle the Intent](#handle-the-intent)
- [Create the Skill](#create-the-skill)
- [Resources](#resources)
<!-- /TOC -->

## Alexa Basic Toolkit
The package `alexa` is very basic toolkit to decipher the request from Alexa and generate the appropriate response JSON.
* `alexa.is_request_valid` - Validates the request by comparing the submitted Amazon skills ID against what is the expected value.
* `alexa.get_request_type` - Parses the request JSON to determine the request type.
* `alexa.get_intent` - Parses the request JSON and returns the intent.
* `alexa.generate_response` - Generates the response JSON.

## The REST Data Service
A single POST handler is probably sufficient in most cases since the JSON payload contains the necessary details about the request from Alexa. The sample [script](scripts/create_askme_rest_service.sql) will do the following:

1. Enable the current schema for ORDS and sets the base path to `<USER>-alexa`. You may change these, but it must be unique.
2. Creates a module. Customise the module name and base path, e.g. `askme.v1` (v1 is not required, but useful for versioning the API) and `/askme/v1/`.
3. Define a template. Set the pattern, e.g. `sayHello`.
4. Creates a `POST` handler that generates a response using PL/SQL.

> After executing the script, be sure to do a `commit`!

The final URI to access your service would look like:

`https://<FQDN>:<PORT>/<ORDS_CONTEXT_PATH>/<SCHEMA_BASE_PATH>/<MODULE_BASE_PATH>/<TEMPLATE_PATTERN>`

For example:

`https://api.contoso.com/ords/demo-alexa/askme/v1/sayHello`


## Create the Skill

1. Create the new skill using ASK:
```
$ ask new --skill-name AskmeBot
```

2. Update the skills manifest (`skill.json`) and make sure it contains the endpoint information (credit: [@tschf](https://github.com/tschf)):
```
{
  "manifest": {

    ...

    "apis": {
      "custom": {
        "endpoint": {
          "uri": "https://api.contoso.com/ords/demo-alexa/askme/v1/sayHello",
          "sslCertificateType": "Trusted"
        }
      }
    },
    "manifestVersion": "1.0"
  }
}
```

3. Update the interaction model and then deploy the skill:
```
$ ask deploy
```

## Handle the Intent

The meat is in the `askme` package where the code for handling the request and intent is embedded. After the skill has been deployed, be sure to update the value of `askme.gc_amazon_skill_id` with the value updated in the file `.ask/config`.

## Resources
* Amazon Alexa Skills
    * [Request and Response JSON Reference](https://developer.amazon.com/docs/custom-skills/request-and-response-json-reference.html)
    * [Request Types Reference](https://developer.amazon.com/docs/custom-skills/request-types-reference.html)
* Oracle REST Data Services
    * [ORDS PL/SQL Package Reference](https://docs.oracle.com/cd/E56351_01/doc.30/e87809/ORDS-reference.htm#AELIG90180)
    * [OAUTH PL/SQL Package Reference](https://docs.oracle.com/cd/E56351_01/doc.30/e87809/OAUTH-reference.htm#AELIG90186)
