---

# 🔹 EXPERIMENT 1 — SQL Injection using Burp Suite

## Aim
To perform SQL Injection attack using Burp Suite on OWASP Juice Shop.

---

# PART 1 — Setup Juice Shop

## Step 1: Install Docker
Open Kali Linux terminal:

sudo apt update

sudo apt install docker.io -y

sudo systemctl start docker

sudo systemctl enable docker

Check installation:
docker --version

Add current user to Docker group:
sudo usermod -aG docker $USER

Restart system:
reboot

Test Docker:
docker run hello-world

---

## Step 2: Download OWASP Juice Shop

docker pull bkimminich/juice-shop

---

## Step 3: Run Juice Shop

docker run -d -p 3000:3000 bkimminich/juice-shop

---

## Step 4: Open Application

Open browser:
http://localhost:3000

---

# PART 2 — Burp Suite Setup

## Step 5: Open Burp Suite

Open terminal:
burpsuite

- Select Temporary Project
- Click Start Burp

---

## Step 6: Open Burp Browser

In Burp:
- Proxy → Open Browser

---

## Step 7: Open Login Page

In Burp browser open:

http://localhost:3000/#/login

---

# PART 3 — SQL Injection Attack

## Step 8: Enter Dummy Credentials

Email:
admin

Password:
password

Click Login

---

## Step 9: Capture Request

In Burp:
- Go to HTTP History
- Find:
  /rest/user/login

---

## Step 10: Send to Intruder

Right-click request:
Send to Intruder

---

## Step 11: Configure Positions

Go to:
Intruder → Positions

Click:
Clear §

Highlight:
"email":"admin"

Click:
Add §

Now:
"email":"§admin§"

---

## Step 12: Add SQL Payloads

Go to:
Payloads tab

Payload examples:

' OR 1=1 --
' OR '1'='1
admin' --
' OR 1=1#
' OR ''='

---

## Step 13: Disable URL Encoding

Uncheck:
URL Encode these characters

---

## Step 14: Start Attack

Click:
Start Attack

---

## Step 15: Analyze Responses

Look for:
Status Code = 200

If found:
SQL Injection successful

---

## Step 16: Extract Token

Open successful response

Find:
authentication token

Copy JWT token

---

## Step 17: Decode Token

Go to:
Decoder tab

Paste token

Decode Base64

---

## Step 18: Extract Credentials

Possible output:
email: admin@juice-sh.op
password: admin123

---

## Step 19: Login

Use extracted credentials

Successfully login

---

## Result

SQL Injection vulnerability successfully exploited.

---

# 🔹 EXPERIMENT 2 — Cross Site Scripting (XSS)

## Aim
To perform reflected and stored XSS attacks.

---

# PART 1 — Setup

## Step 1: Run Juice Shop

docker pull bkimminich/juice-shop

docker run -d -p 3000:3000 bkimminich/juice-shop

---

## Step 2: Open Juice Shop

http://localhost:3000

---

## Step 3: Open Burp Suite

- Proxy → Intercept OFF

---

## Step 4: Configure Proxy

Set browser proxy:

IP:
127.0.0.1

Port:
8081

---

## Step 5: Verify Burp Connection

Open:
http://localhost:3000

Requests should appear in HTTP History

---

# PART 2 — Reflected XSS

## Step 6: Find Input Fields

Search bars
Feedback forms
Login forms

---

## Step 7: Send Request to Repeater

Proxy → HTTP History

Right-click request:
Send to Repeater

---

## Step 8: Inject Payload

Payload:

<script>alert("XSS")</script>

---

## Step 9: Send Request

Click Send

If popup appears:
XSS successful

---

# PART 3 — Stored XSS

## Step 10: Open Feedback Form

Go to:
Contact Us / Feedback

---

## Step 11: Enter Payload

<script>document.write('<img src=x onerror=alert("Stored XSS")>');</script>

---

## Step 12: Submit Form

Reload page

If popup appears:
Stored XSS successful

---

## Result

Reflected and Stored XSS attacks demonstrated successfully.

---

# 🔹 EXPERIMENT 3 — Broken Authentication & Session Management

## Aim
To identify authentication and session vulnerabilities.

---

# PART 1 — Setup

## Step 1: Install Docker

sudo apt update

sudo apt install docker.io -y

sudo systemctl start docker

sudo systemctl enable docker

---

## Step 2: Run Juice Shop

sudo docker run -d -p 3000:3000 --name juice-shop bkimminich/juice-shop

Check:
sudo docker ps

---

## Step 3: Open Application

http://localhost:3000

---

## Step 4: Configure Burp

- Proxy → Intercept ON

Browser proxy:
IP: 127.0.0.1
Port: 8080

---

# PART 2 — Authentication Testing

## Test 1: SQL Injection Login Bypass

### Step 1:
Open Login page

### Step 2:
Enter:

Email:
' OR 1=1 --

Password:
anything

### Step 3:
Forward request

If login succeeds:
SQL Injection vulnerability exists

---

## Test 2: Weak Password Policy

### Step 1:
Register account

### Step 2:
Use password:
12345

If accepted:
Weak password policy exists

---

## Test 3: Brute Force Attack

### Step 1:
Capture login request

### Step 2:
Send to Intruder

### Step 3:
Select password field

### Step 4:
Load wordlist:

/usr/share/wordlists/rockyou.txt

### Step 5:
Start attack

If password found:
No rate limiting vulnerability exists

---

## Test 4: Username Enumeration

### Step 1:
Use valid email + wrong password

### Step 2:
Use invalid email + wrong password

If messages differ:
Username enumeration vulnerability exists

---

# PART 3 — Session Management Testing

## Test 5: Session Cookie Analysis

### Step 1:
Login

### Step 2:
Press F12

Go:
Application → Cookies

Check:
- Session token
- HTTPOnly
- Secure flags

---

## Test 6: Session Hijacking

### Step 1:
Copy session cookie

### Step 2:
Open another browser

### Step 3:
Replace cookie

If access granted:
Session hijacking possible

---

## Test 7: Session Fixation

### Step 1:
Note session ID before login

### Step 2:
Login

### Step 3:
Compare session IDs

If same:
Session fixation vulnerability exists

---

## Test 8: Logout Mechanism

### Step 1:
Copy cookie

### Step 2:
Logout

### Step 3:
Reuse cookie

If session works:
Logout invalidation vulnerability exists

---

## Test 9: JWT Token Analysis

### Step 1:
Copy JWT token

### Step 2:
Go to:
https://jwt.io

### Step 3:
Paste token

Analyze payload

---

## Result

Authentication and session vulnerabilities successfully identified.

---

# 🔹 EXPERIMENT 4 — Cross Site Request Forgery (CSRF)

## Aim
To perform CSRF attack in OWASP Juice Shop.

---

# PART 1 — Setup

## Step 1: Start Juice Shop

docker run -d -p 3000:3000 bkimminich/juice-shop

---

## Step 2: Login

Open:
http://localhost:3000

Login using valid account

---

## Step 3: Keep Session Active

Do NOT logout

---

# PART 2 — Capture Legitimate Request

## Step 4: Open Network Tab

Press:
F12 → Network

---

## Step 5: Change Profile

Modify profile info

Observe request:

POST /rest/user/profile

---

# PART 3 — Create CSRF Attack

## Step 6: Create HTML File

Create:
csrf.html

Paste:

<html>
<head>
<title>CSRF Attack Demo</title>
</head>

<body onload="document.forms[0].submit()">

<form action="http://localhost:3000/rest/user/profile" method="POST">

<input type="hidden" name="username" value="student">

<input type="hidden" name="email" value="attacker@example.com">

</form>

</body>
</html>

---

## Step 7: Save File

Save as:
csrf.html

---

## Step 8: Execute Attack

Open csrf.html in browser

Since victim is logged in:
Request automatically executes

---

## Step 9: Verify Attack

Check profile/email changed

---

## Result

CSRF attack successfully demonstrated.

---

# 🔹 EXPERIMENT 10 — Password Strength Checker using Python

## Aim
To classify passwords as Weak, Medium, or Strong.

---

# PART 1 — Create Program

## Step 1: Open VS Code or Terminal

Create file:
password_checker.py

---

## Step 2: Paste Code

import re

def check_password_strength(password):

    if len(password) < 8:
        return "Weak: Password must be at least 8 characters long."

    if not any(char.isdigit() for char in password):
        return "Weak: Password must include at least one number."

    if not any(char.isupper() for char in password):
        return "Weak: Password must include at least one uppercase letter."

    if not any(char.islower() for char in password):
        return "Weak: Password must include at least one lowercase letter."

    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        return "Medium: Add special characters to make your password stronger."

    return "Strong: Your password is secure!"

def password_checker():

    print("Welcome to the Password Strength Checker!")

    while True:

        password = input("\nEnter your password (or type 'exit' to quit): ")

        if password.lower() == "exit":
            print("Thank you for using the Password Strength Checker! Goodbye!")
            break

        result = check_password_strength(password)
        print(result)

if __name__ == "__main__":
    password_checker()

---

# PART 2 — Run Program

## Step 3: Open Terminal

Navigate to file location:

cd <folder_path>

---

## Step 4: Run Program

python password_checker.py

---

# PART 3 — Test Passwords

## Weak Password

Input:
abc123

Output:
Weak: Password must be at least 8 characters long.

---

## Medium Password

Input:
Abcdef12

Output:
Medium: Add special characters to make your password stronger.

---

## Strong Password

Input:
Abc@1234

Output:
Strong: Your password is secure!

---

## Step 5: Exit Program

Type:
exit

---

## Result

Password strength successfully analyzed using Python.

---

---

# 🔹 EXPERIMENT 15 — Android App Traffic Analysis (Burp Suite)

## Aim
To intercept and analyze HTTP & HTTPS traffic from an Android emulator.

---

## Step 1: Install Android Studio
- Download from: https://developer.android.com/studio
- Install with default settings

---

## Step 2: Create Emulator
- Open Android Studio → AVD Manager
- Click "Create Virtual Device"
- Choose device (Pixel 2 or Pixel 9)
- Download system image → Finish

---

## Step 3: Start Emulator with Proxy
Open terminal:
cd ~/Android/Sdk/emulator
./emulator -list-avds
./emulator -avd Pixel_9 -http-proxy http://10.0.2.2:8080

---

## Step 4: Configure Proxy via ADB
cd ~/Android/Sdk/platform-tools
adb devices
adb shell settings put global http_proxy 10.0.2.2:8080

---

## Step 5: Setup Burp Suite
- Open Burp Suite
- Proxy → Options → set listener to ALL INTERFACES
- Proxy → Intercept → ON

---

## Step 6: Capture HTTP Traffic
- Open Chrome in emulator
- Visit any site (example.com)
- Check Burp → HTTP History

---

## Step 7: Enable HTTPS Interception
- In Burp: Proxy → Options → Export CA Certificate (DER format)

Push to emulator:
adb push burpcer.der /sdcard/Download/

Install:
Settings → Security → Install Certificate → CA Certificate

---

## Step 8: Verify
- Open HTTPS site (https://example.com)
- Check Burp → traffic visible

---

## Result
Successfully intercepted Android HTTP & HTTPS traffic

---

# 🔹 EXPERIMENT 16 — IoT Device Security Testing

## Aim
To detect open ports, services, and weak authentication.

---

## Step 1: Run Vulnerable App
docker run -d -p 8090:3000 bkimminich/juice-shop

---

## Step 2: Find Host IP
On Windows:
ipconfig

---

## Step 3: Scan Using Kali
start kali linux vm
nmap -sV <target_ip>

---

## Step 4: Analyze Results
Check:
- Open ports
- Services running
- Version info

---

## Step 5: Access Dashboard
Open browser:
http://<target_ip>:8090

---

## Step 6: Test Credentials
Try:
admin@juice-sh.op / admin123

---

## Step 7: Check Traffic
- Open DevTools → Network
- Observe HTTP (plaintext)

---

## Result
Identified open ports, weak passwords, unencrypted traffic

---

# 🔹 EXPERIMENT 17 — Disk Imaging & Forensics (Corrected)

## Aim
To create and analyze a forensic disk image

---

## PART 1: Create Disk & Evidence
Go to Kali linux VM
### Step 1: Create Disk
dd if=/dev/zero of=practice_disk.dd bs=1M count=100

### Step 2: Format Disk
mkfs.ext4 practice_disk.dd

### Step 3: Create Mount Folder
sudo mkdir /mnt/practice

### Step 4: Mount Disk
sudo mount -o loop practice_disk.dd /mnt/practice

### Step 5: Create Evidence File
echo "Cybersecurity Lab Evidence" | sudo tee /mnt/practice/evidence.txt

### Step 6: Verify
ls /mnt/practice

### Step 7: Unmount Disk
sudo umount /mnt/practice

---

## PART 2: Create Forensic Image

### Step 8: Create Image
sudo dd if=practice_disk.dd of=disk_image.dd bs=4M

### Step 9: Verify
ls

---

## PART 3: Analyze Using Autopsy

### Step 10: Start Autopsy
sudo autopsy

Open:
http://localhost:9999/autopsy

---

### Step 11: Create Case
- New Case → Name: Lab1 → Next → Next

---

### Step 12: Add Image
Path:
/home/kali/disk_image.dd

Select:
✔ Partition  
✔ Symlink  

---

### Step 13: Enable Hash
✔ Calculate hash value → Add → OK

---

### Step 14: Analyze
Click ANALYZE

---

## PART 4: Find Evidence

### Step 15: File Analysis
- Open File Analysis
- Navigate folders
- Open evidence.txt

Output:
Cybersecurity Lab Evidence

---

### Step 16: Keyword Search (Optional)
Search: Cybersecurity

---

## Result
✔ Disk image created  
✔ Evidence recovered  
✔ Hash verified  

---

# 🔹 EXPERIMENT 18 — Log File Analysis

## Step 1: Open Logs
cd /var/log
ls

---

## Step 2: View Logs
journalctl | less

---

## Step 3: Failed Logins
journalctl | grep "Failed"

---

## Step 4: SSH Activity
journalctl | grep ssh

---

## Step 5: Extract Suspicious IP
journalctl | grep "Failed password" | awk '{print $11}'

---

## Step 6: Count Attempts
journalctl | grep "Failed password" | awk '{print $11}' | sort | uniq -c | sort -nr

---

## Step 7: Simulate Attack
sudo apt install openssh-server -y
sudo service ssh start
ssh fakeuser@localhost

---

## Result
Detected brute-force attempts from logs

---

# 🔹 EXPERIMENT 19 — Network Forensics (Wireshark)

## Step 1: Start Wireshark
wireshark &

---

## Step 2: Select Interface
Choose eth0 or wlan0

---

## Step 3: Apply Filters
tcp
udp
http
ip.addr == <IP>

---

## Step 4: Follow Stream
Right click → Follow → TCP Stream

---

## Step 5: Simulate Attack
nmap -sS <target_ip>

---

## Step 6: Detect Scan
tcp.flags.syn == 1 && tcp.flags.ack == 0
Check Stats->capture file properties, stats->Resolved adresses, stats->Protocol Heirarchy ,stats->Conversations, stats->End points, stats->IO Graph

---

## Result
Captured and analyzed suspicious traffic

---

# 🔹 EXPERIMENT 20 — Privacy Audit

## Step 1: Install Tools
sudo apt update
sudo apt install nodejs npm -y
sudo npm install -g nativefier

---

## Step 2: Create App
nativefier https://web.whatsapp.com

---

## Step 3: Run App
cd WhatsAppWeb-linux-x64
./WhatsAppWeb

---

## Step 4: Login
Scan QR using phone

---

## Step 5: Analyze Trackers
https://reports.exodus-privacy.eu.org

---

## Step 6: Capture Traffic
wireshark

Filters:
tls
dns

---

## Result
Observed encrypted traffic and trackers

---

# 🔹 EXPERIMENT 21 — Windows Security Audit

## Step 1: System Info
winver
msinfo32

---

## Step 2: Windows Updates
Settings → Windows Update → Check for updates

---

## Step 3: Firewall
Search → Windows Defender Firewall → Turn ON

---

## Step 4: Antivirus
Open Windows Security → Enable protection

---

## Step 5: Password Security
Settings → Accounts → Sign-in options

---

## Step 6: Installed Apps
Settings → Apps → Installed apps

---

## Step 7: Startup Apps
Ctrl + Shift + Esc → Startup

---

## Step 8: Network
Settings → Network → Ensure Private

---

## Step 9: Browser Security
Chrome → Privacy & Security → Enable Safe Browsing

---

## Step 10: Backup
Settings → Backup → Enable

---

## Result
System vulnerabilities identified and mitigated

---

# 🔹 EXPERIMENT 22 — AWS Cloud Security

## Step 1: Create IAM User
AWS Console → IAM → Users → Add User
Attach: AdministratorAccess

---

## Step 2: Enable MFA
IAM → Security Credentials → Assign MFA

---

## Step 3: Security Group
EC2 → Security Groups

Allow:
- SSH (22)
- HTTP (80)
- HTTPS (443)

---

## Step 4: Launch EC2
EC2 → Launch Instance
Select:
- t2.micro
- Key pair
- Security group

---

## Step 5: Create S3 Bucket
S3 → Create Bucket

---

## Step 6: Enable CloudTrail
CloudTrail → Create Trail

---

## Result
Secure AWS environment configured

---

# ⚡ FINAL MEMORY MAP

15 → Android + Burp  
16 → Nmap IoT  
17 → dd + Autopsy  
18 → Logs + SSH  
19 → Wireshark  
20 → Privacy audit  
21 → Windows audit  
22 → AWS security  

---
