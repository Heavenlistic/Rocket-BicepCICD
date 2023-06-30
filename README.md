To deploy resources using modules and Pipeline
1. Created a manual service connection in Azure Devops
2. in the azure-pipelines.yml, updated the azureSubscription on line 10 
3. In the akscluster.bicep, updated param nodeCount int from 3 to 1 



Commands
1. git init >  git add . > git commit -m "initial commit" 
2. git remote add origin (git link) 
   git branch -M main 
   git push -u origin --all
3. git add . > git commit -m "Second commit > git push (for updated changes)
