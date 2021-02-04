# dataexfil-ultrasound
**Description:**
A simple script to demonstrate data exfiltration using the ggwave API creating ultrasound audio. The powershell script is a simple wrapper that loops through the data you provide it. It performs a base64 encoding and submits it as a simple GET request to a the a library called GGwave from its public hosted web service. The wave file is downloaded locally and clobbered with each record loop. Note that the sample-data.csv has hard coded values for parsing the columns. You need to change this if you need to customize the data. This is only an educational demo PoC. 

**The Why?**
Imagine you're a pen tester on-site and you've got your data staged and undetected. However typical USB endpoint controls and the client has full network visibility. What's next? Use sound. You could have this script running at night to a receiving tablet or host that you will capture the artifacts to.

**Caveats:**
*Note: There are throttle limits and you may need to adjust delays in the sleep calls depending on the noise in the background of your env. Your speakers should be turned up for whatever device will be receiving it. There are basic built in safety mechanisms for not totally ruining your default Windows sound scheme events. However, you should keep a backup of your registry as noted in the script. Should the web service become inaccessible. You will need to download and use the GGwave library locally in a Linux host.*

**Run Instructions:**
 - Get the Waver: Data Over Sound demo apps if desired. Or use the local library or public API provided: https://github.com/ggerganov/ggwave
 - Git clone or download the PS1 and Sample CSV
 - Open PowerShell v3 or higher with right click -> Run as Administrator 
 - Run: Set-ExecutionPolicy -ExecutionPolicy bypass and hit 'Y' for yes
 - Run [dataexfil-ggwaver.ps1](https://github.com/dc401/dataexfil-ultrasound/blob/main/dataexfil-ggwaver.ps1 "dataexfil-ggwaver.ps1")

![enter image description here](https://raw.githubusercontent.com/dc401/dataexfil-ultrasound/main/data_exfil_ultrasound_PoC.png)
