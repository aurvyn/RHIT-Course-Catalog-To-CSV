import std/httpclient, std/json, std/strutils, std/sequtils, std/re

const courses = ["ID", "Name", "Description", "Subject", "Grad Studies Eligible", "Credit Hours", "Term Available", "Prerequisites", "Corequisites"]
let
    client = newHttpClient()
    catalog = parseJson(client.getContent("https://www.rose-hulman.edu/academics/course-catalog/current/index.json"))
    file = open("courses.csv", fmWrite)
    linkHead = re"\s*<a.*\"">"
    linkTail = re"</a>\s*"
file.write(courses.join("|"))
for course in catalog["courses"]:
    var 
        index = 0
        page = client.getContent("https://www.rose-hulman.edu/academics/course-catalog/current/" & ($course["link"])[1..^2].replace(" ", "%20"))
        content : string
    file.write('\n' & [$course["num"], $course["name"], $course["description"], $course["subject"], $course["gradStudiesEligible"]].join("|").replace("\""))
    for section in courses[5..8]:
        index = page.find(section, index)
        content = page[index+len(section)+1..page.find("</li>", index)-1]
        if section in courses[7..8]:
            content = content.multiReplace([(linkHead, " "), (linkTail, " ")]).multiReplace(("\x0D\x0A", ""), (" ,", ",")).split(' ').filter(proc(item: string): bool = item != "").join(" ")
        file.write('|' & content.strip())
client.close()