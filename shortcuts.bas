REM  *****  BASIC  *****

Sub Main

End Sub
REM The following code is from the user librebel from ask.libreoffice.org
REM https://ask.libreoffice.org/en/question/77006/how-can-i-write-a-macro-to-assign-a-shortcut-to-another-macro/
Function getShortCutManager()
	REM Return the ShortCutManager for the current Office Module.
    Dim oModuleManager As Object, oModuleIdent
    Dim oModuleConfigManager As Object, oModuleConfigManagerSupplier As Object
    oModuleManager = createUnoService( "com.sun.star.frame.ModuleManager" )
    oModuleIdent = oModuleManager.identify( ThisComponent )
    oModuleConfigManagerSupplier = createUnoService( "com.sun.star.ui.ModuleUIConfigurationManagerSupplier" )
    oModuleConfigManager = oModuleConfigManagerSupplier.getUIConfigurationManager( oModuleIdent )
    getShortCutManager = oModuleConfigManager.getShortCutManager()
End Function

Sub SetCommandShortcut( oKeyEvent, strCommandURL as String )
	REM Adapted from code by Paolo Mantovani.
	REM Connects a Keyboard Shortcut to a certain Command, such as a macro or UNO dispatch.
	REM   <oKeyEvent>:      com.sun.star.awt.KeyEvent representing the Keyboard Shortcut for this Command.
	REM   <strCommandURL>:  the Command to which the Keyboard Shortcut will be attached.
	REM Example call:
	REM strCommandURL = "vnd.sun.star.script:Standard.Module1.Main?language=Basic&location=document"
	REM oKeyEvent = CreateKeyEvent( 2, com.sun.star.awt.Key.J )     REM Ctrl-J
	REM SetCommandShortcut( oKeyEvent, strCommandURL )
    Dim oShortCutManager As Object
    oShortCutManager = getShortCutManager()
    oShortCutManager.setKeyEvent( oKeyEvent, strCommandURL )
    oShortCutManager.store()
End Sub
Function CreateKeyEvent( iModifiers as Integer, iKeyCode as Integer ) As com.sun.star.awt.KeyEvent
	REM Construct and return a KeyEvent structure.
    Dim aKeyEvent As New com.sun.star.awt.KeyEvent
    aKeyEvent.Modifiers = iModifiers
    aKeyEvent.KeyCode = iKeyCode
    CreateKeyEvent = aKeyEvent
End Function

Sub RemoveCommandShortcut( strCommandURL as String )
	REM Removes all the Keyboard Shortcut(s) associated with the specified Command.
	REM <strCommandURL>: a Command that has one or more Keyboard Shortcuts to be removed from it.
    Dim oShortCutManager As Object
    oShortCutManager = getShortCutManager()
    oShortCutManager.removeCommandFromAllKeyEvents( strCommandURL ) 
    oShortCutManager.store()
End Sub