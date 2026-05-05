# 🧪 CYBERSECURITY & DIGITAL FORENSICS LAB (EXP 15–22)
# Beginner-Friendly Step-by-Step Guide

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
admin / admin

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
