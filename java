---
syntax: markdown
tags: [tldr, common]
source: https://github.com/tldr-pages/tldr.git
---
# java

> Java application launcher.
> More information: <https://docs.oracle.com/en/java/javase/20/docs/specs/man/java.html>.

- Execute a Java `.class` file that contains a main method by using just the class name:

`java {{classname}}`

- Execute a Java program and use additional third-party or user-defined classes:

`java -classpath {{path/to/classes1}}:{{path/to/classes2}}:. {{classname}}`

- Execute a `.jar` program:

`java -jar {{filename.jar}}`

- Execute a `.jar` program with debug waiting to connect on port 5005:

`java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005 -jar {{filename.jar}}`

- Display JDK, JRE and HotSpot versions:

`java -version`

- Display help:

`java -help`
