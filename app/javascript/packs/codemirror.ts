import CodeMirror, { commands } from 'codemirror'
import 'codemirror/addon/mode/overlay'// Seems to solve https://github.com/3scale/porta/blob/25fa9bc53bdd3eeb8f2a9c8e882f771c85c3c3cb/app/views/provider/admin/cms/_codemirror.html.erb#L34
import 'codemirror/mode/css/css' // Formats and styles for CSS; Used in CMS
import 'codemirror/mode/htmlmixed/htmlmixed' // Formats and syles for HTML and Liquid; Used in CMS
import 'codemirror/mode/javascript/javascript' // Formats and syles for JSON; Used in ActiveDocs and in CMS
import 'codemirror/mode/xml/xml' // Formats and syles for XML

/**
* Adds a shortcut to "save" the codemirror editor. When Ctrl-S or Cmd-S is pressed, click Save
* button. More info at https://codemirror.net/5/doc/manual.html#commands
* TODO: the save button should really be disabled unless Codemirror has unsaved changes.
*/
// @ts-expect-error -- Add a custom callback to "save" command.
commands.save = () => {
  document
    .querySelector<HTMLInputElement>('#edit_cms_template #codemirror_save_button')
    ?.click()
}

window.CodeMirror = CodeMirror
