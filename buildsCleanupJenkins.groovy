import com.cloudbees.hudson.plugins.folder.*

def jobNamesRegex = "^(?i:RegExp-Example)\$"
def jobNames = Jenkins.instance.items.findAll{it.name=~/${jobNamesRegex}/}.name

println "Jobs: ${jobNames}\n"

def items = new LinkedHashSet()

if (jobNames != null && jobNames != "") {
  for (jobName in jobNames) {
    def job = Hudson.instance.getJob(jobName)
    if (job instanceof Folder) {
      items.addAll(job.getItems())
    } else {
      items.add(job)
    }
  }
}

for (item in items) {
  item.builds.findAll{it.keepLog==true}.each{ build ->
    println "Disabling keepLog: ${build}"
    //build.keepLog(false) // remove "keep this build forever" flag from all builds
  }
  for (build in item.builds) {
    def recent = item.builds.limit(50) // last 50 builds
    if (!recent.contains(build)) {
      println "Deleting: ${build}"
      //try { build.delete() } catch (IOException ignore) {} // remove all but last 50 builds
    }
  }
}
