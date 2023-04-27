import CodeMirror from 'codemirror'
import 'codemirror/addon/mode/overlay'// Seems to solve https://github.com/3scale/porta/blob/25fa9bc53bdd3eeb8f2a9c8e882f771c85c3c3cb/app/views/provider/admin/cms/_codemirror.html.erb#L34
import 'codemirror/mode/css/css' // Formats and styles for CSS; Used in CMS
import 'codemirror/mode/htmlmixed/htmlmixed' // Formats and syles for HTML and Liquid; Used in CMS
import 'codemirror/mode/javascript/javascript' // Formats and syles for JSON; Used in ActiveDocs and in CMS
import 'codemirror/mode/xml/xml' // Formats and syles for XML

window.CodeMirror = CodeMirror
