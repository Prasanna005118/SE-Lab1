# Cloud Computing Lab — Experiments 7 to 13

> **How to use this guide:** Follow each experiment top-to-bottom. Every step, command, and code block is included. No prior experience required — just an AWS account.

---

## Table of Contents

- [Experiment 7 — AWS Lambda (S3 → DynamoDB)](#experiment-7--aws-lambda-s3--dynamodb)
- [Experiment 8 — SNS, SQS & S3-SNS-SQS-Lambda Pipeline](#experiment-8--sns-sqs--s3-sns-sqs-lambda-pipeline)
- [Experiment 9 — Elastic Load Balancer with Auto Scaling](#experiment-9--elastic-load-balancer-with-auto-scaling)
- [Experiment 10 — Elastic Beanstalk](#experiment-10--elastic-beanstalk)
- [Experiment 11 — Amazon Lex Chatbot](#experiment-11--amazon-lex-chatbot)
- [Experiment 12 — IAM User with GUI and CLI Access](#experiment-12--iam-user-with-gui-and-cli-access)
- [Experiment 13 — Attach IAM Role to EC2 for S3 Access (No Keys)](#experiment-13--attach-iam-role-to-ec2-for-s3-access-no-keys)

---

## Experiment 7 — AWS Lambda (S3 → DynamoDB)

**Goal:** Create a Lambda function that automatically triggers whenever a file is uploaded to an S3 bucket, and writes the event details into a DynamoDB table.

---

### Step 1 — Create an AWS Account

If you don't already have one, sign up at [https://aws.amazon.com/](https://aws.amazon.com/).

---

### Step 2 — Log In to the AWS Management Console

Go to [https://console.aws.amazon.com/](https://console.aws.amazon.com/) and sign in.

---

### Step 3 — Create a DynamoDB Table

1. In the search bar, type **DynamoDB** and open the service.
2. Click **Create table**.
3. Set:
   - **Table name:** `newtable2`
   - **Partition key:** `unique` (type: String)
4. Leave all other settings as default.
5. Click **Create table**.

---

### Step 4 — Create the Lambda Function

1. In the search bar, type **Lambda** and open the service.
2. Click **Create function**.
3. Choose **Author from scratch**.
4. Fill in:
   - **Function name:** `S3ToDynamoDB`
   - **Runtime:** Python 3.x (latest)
5. Under **Permissions**, either create a new role with basic Lambda permissions **or** select an existing role that has permissions to access both S3 and DynamoDB.
6. Click **Create function**.

---

### Step 5 — Write and Upload the Lambda Code

1. In the Lambda function page, scroll down to the **Code source** section.
2. Replace the existing code with the following:

```python
import boto3
from uuid import uuid4

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    dynamoTable = dynamodb.Table('newtable2')

    if 'Records' in event:
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            size = record['s3']['object'].get('size', -1)
            event_name = record['eventName']
            event_time = record['eventTime']

            dynamoTable.put_item(
                Item={
                    'unique': str(uuid4()),
                    'Bucket': bucket_name,
                    'Object': object_key,
                    'Size': size,
                    'Event': event_name,
                    'EventTime': event_time
                }
            )
    else:
        print("No S3 event received")

    return {
        "statusCode": 200,
        "body": "Data stored in DynamoDB"
    }
```

3. Click **Deploy**.

---

### Step 6 — Add an S3 Trigger

1. In the Lambda function page, click **Add trigger** (in the Function overview section).
2. Select **S3** as the trigger source.
3. Choose the S3 bucket you want to monitor (create one if needed via the S3 console).
4. Under **Event types**, select **All object create events**.
5. Click **Add**.

---

### Step 7 — (Optional) Set Environment Variables

If your function needs environment variables (e.g., region, table name overrides):
1. Go to the **Configuration** tab.
2. Click **Environment variables → Edit**.
3. Add key-value pairs as needed.

---

### Step 8 — Test the Function

1. Click the **Test** button in the Lambda console.
2. Create a new test event. You can use a sample S3 event template (select "s3-put" from the event templates list).
3. Click **Test** and verify the output shows `"statusCode": 200`.

---

### Step 9 — Deploy and Monitor

1. Click **Deploy** to finalize.
2. Upload a file to your S3 bucket.
3. Go to the **Monitor** tab of the Lambda function → click **View CloudWatch logs** to see execution logs.
4. Open DynamoDB → **newtable2** → **Explore table items** to confirm the record was written.

---

## Experiment 8 — SNS, SQS & S3-SNS-SQS-Lambda Pipeline

**Goal:** This experiment has three parts:
- **Part A:** Create an SNS Topic and send an email notification.
- **Part B:** Trigger an email when a file is uploaded to S3 (S3 → SNS → Email).
- **Part C:** Build a full serverless pipeline: S3 → SNS → SQS → Lambda.

---

### Part A — SNS: Create a Topic and Send an Email

#### Step 1 — Create an SNS Topic

1. In the AWS Console search bar, type **SNS** and open **Amazon Simple Notification Service**.
2. In the left panel, click **Topics**.
3. Click **Create topic**.
4. Configure:
   - **Type:** Standard
   - **Name:** `MyEmailTopic`
   - Leave other settings default.
5. Click **Create topic**.

#### Step 2 — Create an Email Subscription

1. Open the topic you just created (`MyEmailTopic`).
2. Go to the **Subscriptions** tab.
3. Click **Create subscription**.
4. Configure:
   - **Protocol:** Email
   - **Endpoint:** Enter your email address
5. Click **Create subscription**.

#### Step 3 — Confirm the Subscription

1. Check your email inbox for a message from **Amazon SNS**.
2. Click the **Confirm subscription** link in the email.
3. Your email is now successfully subscribed.

#### Step 4 — Publish a Test Message

1. Go back to your SNS topic (`MyEmailTopic`).
2. Click **Publish message**.
3. Fill in:
   - **Subject:** `Test Mail`
   - **Message body:** `Hello this is SNS test`
4. Click **Publish message**.
5. You should receive an email notification shortly.

---

### Part B — S3 → SNS → Email Notification

#### Step 1 — Create an S3 Bucket

1. In the search bar, type **S3** and open Amazon S3.
2. Click **Create bucket**.
3. Configure:
   - **Bucket name:** `my-upload-bucket-2026` (must be globally unique)
   - **Region:** Must be the **same region** as your SNS topic
   - Leave all other settings default.
4. Click **Create bucket**.

#### Step 2 — Reuse or Create SNS Topic

Reuse `MyEmailTopic` from Part A. Make sure the email subscription is confirmed.

#### Step 3 — Update the SNS Access Policy (Allow S3 to Publish)

1. Open **SNS → Topics → MyEmailTopic**.
2. Go to the **Access policy** tab → Click **Edit**.
3. Replace the policy content with the JSON below.  
   **Before pasting, replace:**
   - `YOUR_SNS_TOPIC_ARN` → your actual SNS topic ARN
   - `YOUR_BUCKET_ARN` → your actual S3 bucket ARN (format: `arn:aws:s3:::my-upload-bucket-2026`)
   - `YOUR_ACCOUNT_ID` → your 12-digit AWS account ID

```json
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:AddPermission",
        "SNS:Subscribe"
      ],
      "Resource": "YOUR_SNS_TOPIC_ARN",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "YOUR_ACCOUNT_ID"
        }
      }
    },
    {
      "Sid": "AllowS3Publish",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "YOUR_SNS_TOPIC_ARN",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "YOUR_BUCKET_ARN"
        },
        "StringEquals": {
          "aws:SourceAccount": "YOUR_ACCOUNT_ID"
        }
      }
    }
  ]
}
```

4. Click **Save changes**.

#### Step 4 — Configure S3 Event Notification

1. Open your S3 bucket (`my-upload-bucket-2026`).
2. Go to **Properties** tab.
3. Scroll down to **Event notifications**.
4. Click **Create event notification**.
5. Configure:
   - **Event name:** `UploadNotification`
   - **Event types:** All object create events
   - **Destination:** SNS topic → select `MyEmailTopic`
6. Click **Save changes**.

#### Step 5 — Test It

1. Upload any file to the S3 bucket.
2. After upload completes, S3 triggers the event → SNS receives it → SNS sends email.
3. You will receive an email about the object upload. ✅

---

### Part C — Full Pipeline: S3 → SNS → SQS → Lambda

#### Architecture

```
User uploads file
       ↓
  Amazon S3
       ↓
   SNS Topic
       ↓
   SQS Queue
       ↓
Lambda Function (Consumer)
       ↓
Processing / Logs / Database
```

#### Step 1 — Create S3 Bucket

1. Go to **S3 → Create bucket**.
2. Configure:
   - **Bucket name:** `mys3eventbucket123` (must be unique)
   - **Region:** Choose your region
   - Leave other settings default.
3. Click **Create bucket**.

#### Step 2 — Create SNS Topic

1. Go to **SNS → Topics → Create topic**.
2. Configure:
   - **Type:** Standard
   - **Name:** `MyS3SNSTopic`
3. Click **Create topic**.
4. **Copy the SNS Topic ARN** — you'll need it later.

#### Step 3 — Create SQS Queue

1. In the search bar, type **SQS** and open **Amazon Simple Queue Service**.
2. Click **Create queue**.
3. Configure:
   - **Type:** Standard
   - **Name:** `MyS3Queue`
4. Click **Create queue**.
5. **Copy the Queue ARN** — you'll need it later.

#### Step 4 — Subscribe SQS to SNS

1. Open `MyS3SNSTopic` in SNS.
2. Go to **Subscriptions → Create subscription**.
3. Configure:
   - **Protocol:** Amazon SQS
   - **Endpoint:** Select `MyS3Queue`
4. Click **Create subscription**.

#### Step 5 — Update SQS Access Policy

1. Open **SQS → MyS3Queue → Access Policy → Edit**.
2. Replace the policy with the JSON below.  
   **Before pasting, replace:**
   - `YOUR_ACCOUNT_ID` → your 12-digit AWS account ID
   - `YOUR_SQS_ARN` → your SQS queue ARN
   - `YOUR_SNS_TOPIC_ARN` → your SNS topic ARN

```json
{
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR_ACCOUNT_ID:root"
      },
      "Action": "SQS:*",
      "Resource": "YOUR_SQS_ARN"
    },
    {
      "Sid": "Allow-SNS-SendMessage",
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "YOUR_SQS_ARN",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "YOUR_SNS_TOPIC_ARN"
        }
      }
    }
  ]
}
```

3. Click **Save**.

#### Step 6 — Update SNS Access Policy

1. Open **SNS → MyS3SNSTopic → Access policy → Edit**.
2. Replace the policy with the JSON below.  
   **Before pasting, replace:**
   - `YOUR_ACCOUNT_ID`
   - `YOUR_SNS_TOPIC_ARN`
   - `YOUR_S3_BUCKET_ARN` (format: `arn:aws:s3:::mys3eventbucket123`)

```json
{
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:AddPermission",
        "SNS:Subscribe"
      ],
      "Resource": "YOUR_SNS_TOPIC_ARN",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "YOUR_ACCOUNT_ID"
        }
      }
    },
    {
      "Sid": "AllowS3Publish",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "YOUR_SNS_TOPIC_ARN",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "YOUR_S3_BUCKET_ARN"
        },
        "StringEquals": {
          "aws:SourceAccount": "YOUR_ACCOUNT_ID"
        }
      }
    }
  ]
}
```

3. Click **Save**.

#### Step 7 — Configure S3 Event Notification

1. Open your S3 bucket (`mys3eventbucket123`).
2. Go to **Properties → Event notifications → Create event notification**.
3. Configure:
   - **Event name:** `S3UploadEvent`
   - **Event type:** All object create events
   - **Destination:** SNS Topic → `MyS3SNSTopic`
4. Click **Save changes**.

#### Step 8 — Test: Upload a File

1. Open the S3 bucket.
2. Click **Upload** and upload any file (e.g., `test.txt`).
3. The pipeline triggers automatically: S3 → SNS → SQS.

#### Step 9 — Verify Message in SQS

1. Open **SQS → MyS3Queue**.
2. Click **Send and receive messages**.
3. Click **Poll for messages**.
4. You should see the S3 event notification message appear. ✅

#### Step 10 — Create Lambda Consumer

1. Go to **Lambda → Create function**.
2. Configure:
   - **Author from scratch**
   - **Function name:** `SQSConsumerFunction`
   - **Runtime:** Python 3.x
3. Click **Create function**.

#### Step 11 — Add SQS Trigger to Lambda

1. Open `SQSConsumerFunction`.
2. Click **Add trigger**.
3. Select **SQS**.
4. Choose `MyS3Queue`.
5. Click **Add**.

Lambda will now automatically read messages from SQS.

#### Step 12 — Write Lambda Code

In the **Code source** editor, replace the existing code with:

```python
def lambda_handler(event, context):
    for record in event['Records']:
        print("Message received from SQS:")
        print(record['body'])
    return {
        'statusCode': 200,
        'body': 'Message processed successfully'
    }
```

Click **Deploy**.

#### Final Result

When a file is uploaded to S3:
1. S3 sends a notification to SNS
2. SNS forwards the message to SQS
3. SQS stores the message
4. Lambda automatically reads and processes the message ✅

---

## Experiment 9 — Elastic Load Balancer with Auto Scaling

**Goal:** Set up two EC2 web servers behind an Application Load Balancer (ALB), then create an Auto Scaling Group (ASG) that automatically launches and replaces instances based on demand.

---

### Part A — Elastic Load Balancer (ALB)

#### Step 1 — Launch EC2 Instance #1

1. Go to **EC2 Console → Launch Instance**.
2. Configure:
   - **Name:** `webserver-1`
   - **AMI:** Amazon Linux 2
   - **Instance type:** t2.micro
   - **Storage:** Default
3. **Security Group rules:**
   - Allow **SSH (port 22)** from your IP
   - Allow **HTTP (port 80)** from anywhere (`0.0.0.0/0`)
4. Select or create a key pair → Click **Launch Instance**.
5. Once running, **connect to the instance via SSH** and run the following commands:

```bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "This is Server 1" > /var/www/html/index.html
```

#### Step 2 — Launch EC2 Instance #2

Repeat Step 1 with:
- **Name:** `webserver-2`
- Same security group rules and key pair

After connecting via SSH, run:

```bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "This is Server 2" > /var/www/html/index.html
```

#### Step 3 — Create a Security Group for the Load Balancer

1. Go to **EC2 → Security Groups → Create Security Group**.
2. Configure:
   - **Name:** `lb-sg`
   - Allow **HTTP (port 80)** from anywhere
   - (Optional) Allow **HTTPS (port 443)** if using SSL
3. Click **Create security group**.

#### Step 4 — Create the Application Load Balancer

1. Go to **EC2 → Load Balancers → Create Load Balancer → Application Load Balancer**.
2. **Basic Configuration:**
   - **Name:** `my-alb`
   - **Scheme:** Internet-facing
   - **IP address type:** IPv4
3. **Listeners:** HTTP (port 80) — default.
4. **Availability Zones:** Select the default VPC and choose at least two subnets.
5. **Security Groups:** Select `lb-sg`.

#### Step 5 — Create a Target Group

1. When prompted, create a new target group:
   - **Name:** `web-servers-tg`
   - **Target type:** Instance
   - **Protocol:** HTTP
   - **Port:** 80
   - **Health check path:** `/`
2. **Register Targets:**
   - Select `webserver-1` and `webserver-2`
   - Click **Include as pending → Register targets**
3. Review all settings → Click **Create Load Balancer**.

#### Step 6 — Verify the Load Balancer

1. Go to **Load Balancers → Select your ALB → Description → DNS name**.
2. Copy the DNS name (e.g., `my-alb-123456.us-east-1.elb.amazonaws.com`).
3. Paste it into a browser — you should see either "This is Server 1" or "This is Server 2".
4. Refresh the page multiple times — the load balancer alternates traffic between both instances. ✅

#### Step 7 — Check Health Checks

1. Go to **Target Groups → web-servers-tg → Targets**.
2. Ensure both instances show **Status: healthy**.
   - If unhealthy, check the Apache setup or security group rules.

---

### Part B — Auto Scaling Group (ASG)

#### Step 1 — Create an AMI from an Existing EC2 Instance

1. Go to **EC2 Console → Instances**.
2. Select one of your configured instances (`webserver-1`).
3. Click **Actions → Image and Templates → Create Image**.
4. Set:
   - **Image Name:** `my-webserver-AMI`
   - (Optional) Add a description
5. Click **Create Image**.
6. Wait until the AMI status shows **available** (check under **EC2 → AMIs**).

#### Step 2 — Create a Launch Template

1. Go to **EC2 → Launch Templates → Create Launch Template**.
2. Configure:
   - **Launch Template Name:** `my-launch-template`
   - **AMI:** Select `my-webserver-AMI` (created in Step 1)
   - **Instance type:** t2.micro
   - **Key Pair:** Select your existing key pair
   - **Security Groups:** Select the load balancer security group (allows HTTP port 80)
   - **User Data:** Leave blank (already baked into the AMI)
3. Click **Create Launch Template**.

#### Step 3 — Create Auto Scaling Group

1. Go to **EC2 → Auto Scaling Groups → Create Auto Scaling Group**.
2. Configure:
   - **Name:** `webserver-asg`
   - **Launch Template:** `my-launch-template`
   - **Template Version:** Version 1
3. Click **Next**.

**Network Settings:**
- **VPC:** Default VPC
- **Availability Zones:** Select all subnets (for high availability)
- **Load Balancer:** Enable **Attach to an existing load balancer** → select your ALB
- **Health Check Type:** HTTP
- **Health Check Grace Period:** 300 seconds
- Click **Next**.

**Group Size:**
- **Desired Capacity:** 2
- **Minimum Capacity:** 1
- **Maximum Capacity:** 4
- Click **Next**.

4. Review all settings → Click **Create Auto Scaling Group**.

#### Step 4 — Verify

1. Go to **Load Balancers → your ALB → Instances / Target Group → Registered Targets**.
   - You should see 2 healthy instances initially.
2. Go to **Auto Scaling Groups → your ASG → Instances**.
   - You can see up to 4 instances if scaling triggers.

#### Step 5 — Test Auto Recovery

1. **Terminate** one of the running instances manually.
2. Wait a few seconds.
3. The ASG will **automatically launch a new instance** to replace it.
4. Traffic will continue to be distributed by the Load Balancer. ✅

#### Step 6 — Test via Browser

1. Copy the **Load Balancer DNS Name**.
2. Open it in a browser → you should see your web page.
3. Refresh multiple times → traffic alternates between instances. ✅

---

## Experiment 10 — Elastic Beanstalk

**Goal:** Deploy a web application using AWS Elastic Beanstalk, which automatically handles EC2 provisioning, load balancing, and auto scaling.

**Prerequisite:** Have a web application package ready (e.g., a `.war` file for Java/Tomcat, or a `.zip` for Python/Node.js/PHP).

---

### Step 1 — Open Elastic Beanstalk

1. Log in to the **AWS Console**.
2. In the search bar, type **Elastic Beanstalk** (found under Compute).
3. Click **Create Application**.

---

### Step 2 — Create Application

1. Enter **Application Name** (e.g., `MyApp`).
2. Add an optional description.
3. Click **Create**.

---

### Step 3 — Create Environment

1. Click **Create Environment**.
2. Choose **Web Server Environment** (for web apps).
3. Click **Select**.

---

### Step 4 — Configure Environment

1. Enter an **Environment Name** (e.g., `MyApp-env`).
2. Choose a **Platform:**
   - `Tomcat` for `.war` files
   - `Node.js`, `Python`, `PHP`, etc. for other app types
3. Under **Application Code:**
   - Select **Upload your code**
   - Click **Choose file** and upload your `.war` or `.zip` file

---

### Step 5 — Configure Service Access

1. **Service Role:** Select existing → choose `LabRole` (or your available role).
2. **EC2 Key Pair:** Optional (needed only if you want SSH access).
3. **EC2 Instance Profile:** Select `LabInstanceProfile` (or your available profile).

---

### Step 6 — Configure Network

1. **VPC:** Select default VPC (fine for testing).
2. **Subnets:** Select available subnets.
3. **Public IP:** Enable (so the app is accessible from the internet).

---

### Step 7 — Instance & Scaling Setup

1. **Instance type:** `t2.micro` (free tier eligible).
2. Set:
   - **Min instances:** 1
   - **Max instances:** 2 (or more as needed)
3. **Load Balancer:** Enable (recommended for production use).

---

### Step 8 — Review and Create

1. Click **Review**.
2. Click **Create**.

AWS automatically provisions:
- EC2 instances
- Load Balancer
- Auto Scaling Group
- Security Groups

---

### Step 9 — Access Your Application

After deployment completes (a few minutes):
1. Elastic Beanstalk will display a **URL (domain link)** in the environment dashboard.
2. Open that URL in a browser → your app is live. ✅

---

### Step 10 — Update Your Application

To deploy a new version:
1. Go to your environment in Elastic Beanstalk.
2. Click **Upload and Deploy**.
3. Upload your new version file.
4. Click **Deploy**.

---

## Experiment 11 — Amazon Lex Chatbot

**Goal:** Build a hotel booking chatbot using Amazon Lex that collects user inputs (age, city, check-in date, number of nights, room type) and confirms a booking.

---

### Step 1 — Open Amazon Lex

1. Log in to the **AWS Console**.
2. Search for **Amazon Lex** and open the service.
3. Click **Create bot**.

---

### Step 2 — Create the Bot

1. Choose **Create a blank bot**.
2. Configure:
   - **Bot name:** `HotelBookingBot`
   - **IAM role:** Create a new role (default)
   - Leave remaining settings as default → click **Next**
   - **Language:** English
   - **Voice:** Optional
3. Click **Done**.

---

### Step 3 — Create an Intent

1. Go to **Intents** in the left panel.
2. Click **Add intent → Create intent**.
3. **Intent name:** `BookHotel`
4. Click **Create**.

---

### Step 4 — Add Sample Utterances

Utterances are example phrases the user might say to trigger this intent. Add the following:

```
I want to book a hotel
Book a room
Reserve hotel
I need a room
```

---

### Step 5 — Add Slot: Age

Slots are pieces of information the bot collects from the user.

1. Scroll to the **Slots** section → Click **Add slot**.
2. Configure:
   - **Slot name:** `age`
   - **Slot type:** `AMAZON.Number`
   - **Prompt:** `What is your age?`
3. Mark as **Required**.
4. Click **Save**.

**Add IF Condition on Age (Conditional Logic):**
1. In the intent, go to **Slots → age → Advanced options**.
2. Scroll to **Slot capture: success response → Conditional branching**.
3. Click **Add condition**.
4. Set:
   - **Condition:** `{age} < 18`
   - **Response:** `You are not eligible for hotel booking.`
5. Save.

---

### Step 6 — Add Slot: Location

1. Click **Add slot**.
2. Configure:
   - **Slot name:** `location`
   - **Slot type:** `AMAZON.City`
   - **Prompt:** `Which city do you want?`
3. Mark as **Required**.
4. Click **Save**.

---

### Step 7 — Add Slot: Check-in Date

1. Click **Add slot**.
2. Configure:
   - **Slot name:** `checkin`
   - **Slot type:** `AMAZON.Date`
   - **Prompt:** `What is your check-in date?`
3. Mark as **Required**.
4. (Optional) Add a **Retry prompt:** `Please provide a valid date (e.g., 2026-03-25)`
5. Click **Save**.

---

### Step 8 — Add Slot: Number of Nights

1. Click **Add slot**.
2. Configure:
   - **Slot name:** `nights`
   - **Slot type:** `AMAZON.Number`
   - **Prompt:** `How many nights will you stay?`
3. Mark as **Required**.
4. Click **Save**.

---

### Step 9 — Create a Custom Slot Type for Room Type

1. In the left panel, click **Slot Types → Add slot type → Add blank slot type**.
2. **Name:** `RoomType`
3. Add the following values:
   - `Single`
   - `Double`
   - `Suite`
4. Click **Save slot type**.

**Now use this custom slot in the intent:**
1. Go back to the `BookHotel` intent.
2. Click **Add slot**.
3. Configure:
   - **Slot name:** `RoomType`
   - **Slot type:** `RoomType` (your custom type)
   - **Prompt:** `What type of room would you like?`
4. Mark as **Required** → Save.

---

### Step 10 — Add Response Card (Quick Reply Buttons) for Room Type

1. In the `RoomType` slot, go to **Slot prompts → More prompt options**.
2. Click **Add → Add card group**.
3. Configure the card:
   - **Card Title:** `Select Room Type`
4. Click **Add buttons:**
   - Button 1: Label `Single` → Value `Single`
   - Button 2: Label `Double` → Value `Double`
   - Button 3: Label `Suite` → Value `Suite`
5. Save.

---

### Step 11 — Configure Responses

Still within the `BookHotel` intent:

1. **Initial response:** `Welcome to Hotel Booking! What is your age?`
2. **Confirmation prompt:** `Do you want to confirm booking in {location} for {nights} nights?`
3. **Closing response (after confirmation):** `Booking confirmed.`

---

### Step 12 — Build and Test

1. Click **Build** (top right).
2. Once built, open the **Test chatbot** panel on the right.
3. Try the following conversation:

```
User: Book a hotel
Bot:  What is your age?
User: 25
Bot:  Which city do you want?
User: Hyderabad
Bot:  What is your check-in date?
User: Tomorrow
Bot:  How many nights will you stay?
User: 2
Bot:  Select room type  [Single] [Double] [Suite]
User: Double
Bot:  Do you want to confirm booking in Hyderabad for 2 nights?
User: Yes
Bot:  Booking confirmed.
```

✅ Your chatbot is working correctly.

---

## Experiment 12 — Creating an IAM User with GUI and CLI Access

**Goal:** Create an IAM user with restricted permissions (S3 only), verify access via the AWS Console (GUI), then configure the AWS CLI on your local machine and verify CLI-based access.

---

### Part A — Create IAM User and Test GUI Access

#### Step 1 — Log In as Root

Log in to the **AWS Management Console** as the Root User.

#### Step 2 — Open IAM

In the search bar, type **IAM** and open the service (found under Security, Identity & Compliance).

#### Step 3 — Navigate to Users

Click **Users** in the left panel → Click **Create user**.

#### Step 4 — Set User Details

1. **User name:** `S3_Specialist`
2. Check the box **"Provide user access to the AWS Management Console"**
3. Choose **Custom password** and set a password.
4. Click **Next**.

#### Step 5 — Set Permissions

1. Select **"Attach policies directly"**.
2. Search for and select **AmazonS3FullAccess**.
3. Click **Next**.

#### Step 6 — Review and Create

1. Review the settings.
2. Click **Create user**.
3. On the final page, click **Download .csv file** — this contains the login URL, username, and password.

#### Step 7 — Note Your Account ID and Sign Out

1. Find your **12-digit Account ID** in the top-right dropdown of the console.
2. Sign out of the root account.

#### Step 8 — Sign In as IAM User

1. Use the **Sign-in URL** from the downloaded `.csv` file.
   - Alternatively, go to the AWS sign-in page and select **IAM User**.
2. Enter:
   - **Account ID:** your 12-digit account ID
   - **IAM Username:** `S3_Specialist`
   - **Password:** the password you set

#### Step 9 — Test Permissions

**Test 1 — Expected FAILURE (EC2):**
1. Go to **EC2** in the console.
2. Try to view instances.
3. You will see an **"Access Denied"** error. ✅ This confirms the user is restricted to S3 only.

**Test 2 — Expected SUCCESS (S3):**
1. Go to **S3** in the console.
2. Create a new bucket.
3. It works successfully. ✅

---

### Part B — CLI Access (Programmatic Access)

#### Step 1 — Generate Access Keys

1. Log back in as **Admin or Root**.
2. Go to **IAM → Users → S3_Specialist**.
3. Click the **Security credentials** tab.
4. Scroll to **Access keys** → Click **Create access key**.
5. Select **Command Line Interface (CLI)**.
6. Acknowledge the warning → Click **Next**.
7. Click **Download .csv file**.

> ⚠️ **Important:** The `.csv` contains your **Access Key ID** and **Secret Access Key**. If lost, you must delete and recreate them.

#### Step 2 — Install the AWS CLI

**On macOS:**
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**On Windows:** Download the installer from [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/) and run it.

**On Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### Step 3 — Configure the AWS CLI

Open your **Command Prompt** (Windows) or **Terminal** (Mac/Linux) and run:

```bash
aws configure
```

Enter the following from your `.csv` file when prompted:

```
AWS Access Key ID [None]: <your-access-key-id>
AWS Secret Access Key [None]: <your-secret-access-key>
Default region name [None]: ap-south-1
Default output format [None]: json
```

#### Step 4 — Test CLI Access

**Test 1 — Expected FAILURE (EC2):**
```bash
aws ec2 describe-instances
```
Result: `AccessDenied` error — confirms CLI respects the same IAM policy as the GUI. ✅

**Test 2 — Expected SUCCESS (S3):**
```bash
aws s3 ls
```
This should list your existing S3 buckets. ✅

**Test 3 — Create a Bucket via CLI:**
```bash
aws s3 mb s3://your-unique-bucket-name
```
Success — the bucket is created. ✅

**Verify in Console:** Go to **AWS Console → S3** and confirm the new bucket appears.

---

## Experiment 13 — Attach an IAM Role to an EC2 Instance (S3 Access Without Keys)

**Goal:** Give an EC2 instance access to S3 by attaching an IAM Role — no access keys required. The instance uses temporary credentials provided automatically by AWS.

---

### Step 1 — Create an IAM Role

1. Open the **IAM Console**.
2. In the left panel, click **Roles → Create role**.
3. Configure:
   - **Trusted entity type:** AWS Service
   - **Use case:** EC2
4. Click **Next**.

---

### Step 2 — Add Permissions to the Role

1. In the policy search box, type `AmazonS3FullAccess`.
2. Select **AmazonS3FullAccess**.
3. Click **Next**.

---

### Step 3 — Name and Create the Role

1. **Role name:** `EC2-S3-Role`
2. Click **Create role**.

---

### Step 4 — Attach the Role to a Running EC2 Instance

1. Go to **EC2 Dashboard → Instances**.
2. Select your running EC2 instance.
3. Click **Actions → Security → Modify IAM role**.
4. In the dropdown, select **EC2-S3-Role**.
5. Click **Update IAM role**.

---

### Step 5 — Verify Access from Inside the Instance

1. **SSH into your EC2 instance** using your key pair.
2. Run the following commands:

```bash
# Test S3 access — should WORK
aws s3 ls
```

Expected output: A list of your S3 buckets. ✅

```bash
# Test EC2 access — should FAIL (no EC2 permission in the role)
aws ec2 describe-instances
```

Expected output: `UnauthorizedOperation` error. ✅

**Why it works without keys:** The EC2 instance automatically receives **temporary credentials** from the IAM Role via the EC2 metadata service. No access keys are stored on the instance.

---

> **End of Experiments 7–13**
