### Tests are failing as originally the "expected" error message was "Line <LineNo>: Syntax Error In", but then was changed for a more specific message. As the change of message did not alter the logic behind, this should not be a problem as it passed every test before.

### 1. Setting up local environment with Docker (CLI) -> You have to do this once:
 - [Install Docker on Windows](https://docs.docker.com/docker-for-windows/install/#what-to-know-before-you-install).
 - [having hyper-v engine enabled](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v).

    *NOTE: If you are behind a proxy (aka sap proxy), set up proxy for docker. 
    In the docker settings and in the Dockerfile (uncomment two proxy lines).*
- In the root directory, run: 
   
     ```
     docker build . -t compiladores
     ```


### 2. Running the local environment with Docker (CLI):

- The first time that you run Docker, a popup window asking for sharing permissions might appear. If it does, click on **Share It** and enter your network logon credentials.	
  
 - Run the following to start the container:
  
    ```
    docker run -v %cd%:/usr/compiladores -it -d --name compiladores compiladores
    ```

    *NOTE: if you are running the commands on git bash, you may have to change **```%cd%```** for **```$(pwd)```***

- Run the following line to enter container: 
  
    ```
    docker exec -it compiladores bash
    ```

- Now you're good to go, your "compiladores" file is shared between the container and the host machine

    *Happy Hacking :)*
