# Class 7.5 / SEIR-1: Week 4 Class notes - Theo's introduction to Terraform

---

## Table of Contents

- [Introduction](#introduction)
- [Why Is This Tool Needed?](#why-is-this-tool-needed)
- [Development Environment Setup](#development-environment-setup)
- [Basic Terraform](#basic-terraform)
- [Terraform Workflow](#terraform-workflow)
- [The Google Provider](#the-google-provider)


---

## Introduction

This week will be covering the fundamentals of Terraform. This is an automation tool for provisioning and managing cloud infrastructure and other tools. It is a tool in the category called IaC (Infrastructure as Code). It is the most popular IaC tool (by far) and is cloud agnostic, meaning it works in essentially any public cloud and even private clouds.

We will start from the ground up by showing why we need this tool, the issues it fixes, how to set it up, and eventually how to redo the Week 1/2 labs with Terraform from scratch.

For much more detail see [this](../prep/README.md) set of notes. 

### Class Overview

- Introduction
- Discuss prelims and goals
- VS Code, HashiCorp docs
- Discuss the end goal
- Discuss basic HCL syntax
- Build out code
- Terraform workflow
- Troubleshooting

### Preliminary Materials

The script checks the following:

- Google Cloud SDK (in particular, `gcloud`) is installed and authenticated
- Terraform binary is installed and up to date
- TheoWAF folder present at `~/Documents/TheoWAF/class7.5/GCP/Terraform`
- Creates a `.gitignore` file
- Verifies a JSON token is present in the `Terraform` directory

It will create the TheoWAF folder structure if needed and will download a `.gitignore` file configured for Terraform projects. Run this in the Terminal app in MacOS or Git Bash (as an administrator) in Windows. In the future I will expect you to know to use these. 

```bash
curl https://raw.githubusercontent.com/aaron-dm-mcdonald/class7.5-notes/refs/heads/main/week-4/prep/scripts/prelim.sh | sh
```

Next, you need to run this command:
```bash
gcloud auth application-default login
```

If you did the installs and ran the prelim script with no issues the above command should work without issue. This will add *Application Default Credentials* that the Google provider for terraform will use to authenticate (prove who you are) to GCP. 

The final preliminary step is to create a "bucket" in Google Cloud Storage (GCS). If you have been doing the udemy you may have already seen this service. Buckets are known as _object level storage_. It is a infinitely scalable, cost effective storage service that is fully managed by GCP. It has many uses but for today we will use it for something discussed later. For now we will create a bucket with all default settings. Open the GCP console and go to `Cloud Storage` by using the hamburger menu or the search. You should be at this page and the next step is click on "create bucket" as circled:

![](./assets/gcs-1.PNG)

Then name the bucket as shown in step 1. Please note the name *must* be *globally unique* meaning nobody that uses GCP can be using that name. Please save the name of the bucket in your notes. Then simply click the button at the bottom of the wizard as shown in step 2. 

![](./assets/gcs-2.PNG)

Finally you will get a security prompt informing you that the bucket will not be accessible to the public. Simple click on confirm as shown here:

![](./assets/gcs-3.PNG)

Now you will see the bucket details. You are all done with creating the bucket. 

![](./assets/gcs-4.PNG)

- [Cloud Storage product page](https://cloud.google.com/storage?hl=en)
- [Cloud Storage intro](https://docs.cloud.google.com/storage/docs/introduction)
- [Cloud Storage bucket basics](https://docs.cloud.google.com/storage/docs/buckets)
- [Object storage vs other storage](https://cloud.google.com/discover/object-vs-block-vs-file-storage?hl=en)




### Goals

- Pass the prelim script above
- Navigate to the correct directory and prepare VS Code
- Review relevant documentation 
- Familarize yourself with the core terraform workflow
- Setup terraform code block
- Setup provider code block
- Build out resource blocks
- Test and deploy terraform code

---

## Why Is This Tool Needed?

In enterprise environments, automation becomes critical and is one of the main tasks of DevOps. Using the cloud the way we have been so far is called ClickOps, since we click through the console to do things. Cloud infrastructure allows for a great deal of automation, so cloud engineering and Devops have a lot of crossover. Naturally, automating the creation of infrastructure in the cloud follows. There are also other reasons to use this tool, which become clear from the cons of ClickOps.

**Cons of ClickOps:**

- Difficult to reproduce across environments (dev, staging, prod)
- Not self-documenting: no record of what you clicked or why
- Impossible to automate or version control
- No single source of truth that is auditable

---

## Development Environment Setup

Before we dive into Terraform, let's do some initial setup. We will be using the TheoWAF folder, specifically the Terraform subdirectory. We will also be working in VS Code. If you do not have Git Bash (as an administrator) or Terminal open, go ahead and open it now. Run the following 3 commands: 

1. `cd ~/Documents/TheoWAF/class7.5/GCP/Terraform` will take you to the correct directory 
2. `mkdir terraform-041126` will make a directory for today (though you can call it whatever you like)
3. `code terraform-041126/` will open that directory with VS Code

Next we need to make sure on the left in VS Code in the left pane of VS Code (called the "Primary side bar") it says "explorer" like this and the 2 pieces of paper (as circled) is highlighted. This should be the default setting:

![](../assets/make-new-file.PNG)

Next we need to open the "panel" which is a menu in the bottom of VS Code. For now, we will use this menu to access the integrated terminal. To get here on the top tool bar of the page click on Terminal. If you do not see terminal in the top toolbar then click the 3 dots. Then click terminal. Then in the context menu that opens click "New terminal". Like this:

![](../assets/terminal.png)

This next step is for *Windows users only*. For Windows users VS Code's integrated terminal defaults to Powershell but we want Git Bash. In the panel (the new menu that opened at the bottom) click on the chevron and go to default profile like this:

![](../assets/defaultprofile.PNG)

Continuing the step for windows users, we need to choose Git Bash in the menu at the top of the screen that opens (this is called the command palette):
![](../assets/cmd-pal.png)

Finally for windows users, click the new terminal button in the panel:
![](../assets/new-terminal.PNG)

At this point you can close any terminals (on MacOS or Git bash) that are running *outside* of VS code. You should have the GCP console open and the SEIR-1 repo in a web browser. That is all that is needed. 

[VS Code docs](https://code.visualstudio.com/docs/getstarted/userinterface)
[What VS Code should roughly look like now](./assets/code-end.PNG)

## Basic Terraform structure

### Basic Syntax

Before we deploy anything to GCP, let's look at what the language looks like and practice the workflow locally. This section does not require authentication since we are not touching GCP.

Terraform code is organized into **blocks**. A block defines what a section of code is for and usually gives it a unique **label**. A block contains **arguments** which are key-value pairs that configure the block. Arguments are wrapped in curly braces. The general structure:

```hcl
<block type> <label> {
  argument1 = value1
  argument2 = value2
}
```

Indentation is not required by Terraform, but the two-space indent shown above is the idiomatic style recommended by HashiCorp.

[Blocks and arguments docs](https://developer.hashicorp.com/terraform/language/syntax/configuration)

### The Terraform Block

All Terraform configurations should include a `terraform` block. This is largely boilerplate but lets you set the minimum required Terraform version. Add this to `main.tf`:

```hcl
terraform {
  required_version = ">= 1.5"
}
```

This block has no label and one argument, specifying that the configuration requires Terraform 1.5 or higher. Version 1.5 was the last release with major language changes, which is why it is a reasonable floor.

[Terraform block](https://developer.hashicorp.com/terraform/language/block/terraform)
[Version constraints](https://developer.hashicorp.com/terraform/language/expressions/version-constraints)