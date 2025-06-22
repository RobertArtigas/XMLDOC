#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#! Changes:
#! 2021.01.27                       Roberto Artigas
#!  *   Added the section for %ProcedureParameters in the #GROUP(%GetProcedureInfo)
#! 2011.01.27                       Roberto Artigas
#!  *   Created "HandleApplication", "HandleProcedure" tags since they were
#!      producing blank lines in the XML. <Instance></Instance> blocks.
#! 2010.10.05 thru 2010.10.06       Roberto Artigas
#!  *   If an XML block had a type it was moved to the front. This will make it
#!      obvious as to the type of thing. Conditional items can be coded based
#!      on this thing. It could be done anyways, just made more obvious.
#!  *   Re-structure template into several pieces for ease of maintenance.
#!-----------------------------------------------------------------------------
#TEMPLATE(XMLDOC, '2021.01.27 - Generate XML Documentation'), FAMILY('ABC')
#!-----------------------------------------------------------------------------
#GROUP(%XMLDOCMAINBEG)
#!-----------------------------------------------------------------------------
#INCLUDE('XMLDOC_HANDLER.TPW')
#INCLUDE('XMLDOC_COMMON.TPW')
#!-----------------------------------------------------------------------------
#!  X Symbols Dependent on %Application
#!  X Symbols Dependent on %File
#!  X Symbols Dependent on %Field
#!  X Symbols Dependent on %Relation
#!  X Symbols Dependent on %Key and %KeyOrder
#!  X Symbols Dependent on %Procedure
#!  X Symbols Dependent on %Module
#! NA Miscellaneous Symbols
#!  X Window Control Symbols
#!  X File Driver Symbols
#!  X Formula Symbols
#!  X File Schematic Symbols
#!  X Report Control Symbols
#! NA Expansion Symbols
#!  ? Symbols Dependent on %View
#!  X User defined Symbols
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#UTILITY(XMLDOC_APP2XML, '2011.01.27 - Application to XML')
#!
#PREPARE
  #DECLARE(%pDictionaryFile)
  #SET(%pDictionaryFile, %DictionaryFile)
  #CALL(%ReplaceSubString, %pDictionaryFile, '.', '_')
  #SET(%pOutputFile, %pDictionaryFile & '_' & %Application & '.xml')
  #SET(%pLogFile, %pDictionaryFile & '_' & %Application & '_log.txt')
  #SET(%pDateModified, DEFORMAT('Oct 5, 2010', @D4))
#ENDPREPARE
#!
#PROMPT('Output File', SAVEDIALOG('Output File', '*.*')), %pOutputFile, REQ
#PROMPT('Application Info', CHECK), %pExportApplicationInfo, DEFAULT(%True)
#ENABLE(%pExportApplicationInfo)
  #PROMPT('Application Template Info', CHECK), %pExportApplicationTemplateInfo, DEFAULT(%True)
#ENDENABLE
#PROMPT('Module Info', CHECK), %pExportModuleInfo, DEFAULT(%True)
#PROMPT('Procedure Info', CHECK), %pExportProcedureInfo, DEFAULT(%True)
#ENABLE(%pExportProcedureInfo)
  #PROMPT('File Schematic Info', CHECK), %pExportFileSchematicInfo, DEFAULT(%True)
  #PROMPT('Window Info', CHECK), %pExportWindowInfo, DEFAULT(%True)
  #PROMPT('Report Info', CHECK), %pExportReportInfo, DEFAULT(%True)
  #PROMPT('Formula Info', CHECK), %pExportFormulaInfo, DEFAULT(%True)
  #PROMPT('Procedure Template Info', CHECK), %pExportProcedureTemplateInfo, DEFAULT(%True)
#ENDENABLE
#BOXED('Unhandled Templates')
  #PROMPT('Log File', SAVEDIALOG('Log File', '*.*')), %pLogFile   #!, DEFAULT('hjXmlLog.txt')
#ENDBOXED
#INSERT(%Notice)
#!
#DECLARE(%UsedTemplates), MULTI, UNIQUE
#DECLARE(%UsedTemplateIsHandled, %UsedTemplates)
#CREATE(%pOutputFile)
<?xml version="1.0"?>
<ApplicationList>
  #MESSAGE('Processing Application Info', 1)
  #IF(%pExportApplicationInfo)
  #INSERT(%GetApplicationInfo)
    #IF(%pExportApplicationTemplateInfo)
  <TemplateList>
      #FOR(%ApplicationTemplate)
    <Template>
      #INSERT(%GetApplicationTemplateInfo)
    </Template>
      #ENDFOR
  </TemplateList>
    #ENDIF
  #ENDIF
  #MESSAGE('Processing Module Info', 1)
  #IF(%pExportModuleInfo)
  <ModuleList>
    #FOR(%Module)
    <Module>
      #INSERT(%GetModuleInfo)
    </Module>
    #ENDFOR
  </ModuleList>
  #ENDIF
  #IF(%pExportProcedureInfo)
  <ProcedureList>
    #DECLARE(%nProcedure)
    #SET(%nProcedure, 0)
    #EQUATE(%nProcedures, ITEMS(%Procedure))
    #FOR(%Procedure)
      #SET(%nProcedure, %nProcedure + 1)
      #MESSAGE('Processing ' & %nProcedure & ' of ' & %nProcedures & ' (' & %Procedure & ')', 1)
    <Procedure>
      #INSERT(%GetProcedureInfo)
	  #! RA.2022.10.01: FileSchematic is not working
      #IF(%pExportFileSchematicInfo)
      <FileSchematic>
        #INSERT(%GetFileSchematicInfo)
      </FileSchematic>
      #ENDIF
      #IF(%pExportWindowInfo)
      <Window>
        #INSERT(%GetWindowInfo)
      </Window>
      #ENDIF
      #IF(%pExportReportInfo)
      <Report>
        #INSERT(%GetReportInfo)
      </Report>
      #ENDIF
      #IF(%pExportFormulaInfo)
      <FormulaList>
        #FOR(%Formula)
        <Formula>
          #INSERT(%GetFormulaInfo)
        </Formula>
        #ENDFOR
      </FormulaList>
      #ENDIF
      #IF(%pExportProcedureTemplateInfo)
      <ActiveTemplateList>
        #FOR(%ActiveTemplate)
        <Template>
          #INSERT(%GetProcedureTemplateInfo)
        </Template>
        #ENDFOR
      </ActiveTemplateList>
      #ENDIF
    </Procedure>
    #ENDFOR
  </ProcedureList>
  #ENDIF
</ApplicationList>
#CLOSE(%pOutputFile)
#RUN('NOTEPAD.EXE "' & %pOutputFile & '"')
#IF(%pLogFile <> '')
  #CREATE(%pLogFile)
    #FOR(%UsedTemplates), WHERE(NOT %UsedTemplateIsHandled)
%UsedTemplates
    #ENDFOR
  #CLOSE(%pLogFile)
#ENDIF
#!-----------------------------------------------------------------------------
#! RA.2022.11.17: Working thru the #CONTEXT for a #CONTROL item
#! RA.2022.10.01: NOT WORKING !!!!!!
#GROUP(%GetFileSchematicInfo)
       #IF(NOT VAREXISTS(%SearchActiveTemplate))
	     #DECLARE(%SearchActiveTemplate)
	   #ENDIF
  #CASE(UPPER(%ProcedureTemplate))
  #OF  ('REPORT')
  #OROF('UNIVREPORT') 
  #OROF('UNIVABCREPORT') 
  #OROF('RUNTIMEREPORT') 
  #OF  ('PROCESS')
  #OF  ('SOURCE')
  #OF  ('FRAME')
  #OF  ('WINDOW')
  #OF  ('WIDGET')
  #OF  ('BROWSE')
  #OROF('NETWEBBROWSE')
  #OF  ('FORM')
  #OROF('NETWEBFORM')
  #OF  ('CROSSTAB')
  #OF  ('NETWEBPAGE')
  #OF  ('NETWEBPROCEDURE')
  #OF  ('NETWEBSERVICE')
  #OF  ('NETWEBSERVICEMETHOD')
  #OF  ('NETWEBSOURCE')
  #OF  ('NETWEBYEAR')
  #OF  ('NETWEBHANDLEREQUEST')
  #OF  ('EXPORTBASIC')
  #OF  ('IMPORTBASIC')
  #OF  ('BASICIMPORT')
  #OF  ('MHMEMORYREPORT')
  #OF  ('RUNTIMEFILEMANAGER')
  #ENDCASE
	   #CASE(UPPER(%ProcedureCategory))
	   #OF  ('BROWSE')
	     #SET(%SearchActiveTemplate,'BrowseBox(ABC)')
	   #OF  ('FORM')
	     #SET(%SearchActiveTemplate,'SaveButton(ABC)')
	   #OF  ('PROCESS')
       #OF  ('REPORT')
	   #OF  ('WINDOW')
	   #ENDCASE
       #!FOR(%ActiveTemplate),Where(%ActiveTemplate='BrowseBox(ABC)' OR %ActiveTemplate='SaveButton(ABC)')
       #FOR(%ActiveTemplate),Where(%ActiveTemplate=%SearchActiveTemplate)
        #FOR(%ActiveTemplateInstance)
        #Context(%Procedure,%ActiveTemplateInstance)
<PrimaryTable>
#IF(%Primary)
  %(%WriteTag('Primary', %GetStringValue(%Primary)))
  %(%WriteTag('PrimaryKey', %GetStringValue(%PrimaryKey)))
  %(%WriteTag('PrimaryInstance', %PrimaryInstance))
  <SecondaryTableList>
  #FOR(%Secondary)
    <SecondaryTable>
      %(%WriteTag('Secondary', %GetStringValue(%Secondary)))
      %(%WriteTag('SecondaryTo', %GetStringValue(%SecondaryTo)))
      %(%WriteTag('SecondaryType', %GetStringValue(%SecondaryType)))
      %(%WriteTag('SecondaryCustomJoin', %GetBooleanValue(%SecondaryCustomJoin)))
      %(%WriteTag('SecondaryCustomText', %GetStringValue(%SecondaryCustomText)))
      %(%WriteTag('SecondaryInner', %GetBooleanValue(%SecondaryInner)))
    </SecondaryTable>
  #ENDFOR
  </SecondaryTableList>
#ENDIF
</PrimaryTable>
        #EndContext
        #ENDFOR
       #ENDFOR
<OtherTableList>
#FOR(%OtherFiles)
  %(%WriteTag('OtherTable', %GetStringValue(%OtherFiles)))
#ENDFOR
</OtherTableList>
#!-----------------------------------------------------------------------------
#GROUP(%GetFormulaInfo)
%(%WriteTag('Class', %GetStringValue(%FormulaClass)))
%(%WriteTag('ReturnField', %GetStringValue(%Formula)))
%(%WriteTag('Description', %GetStringValue(%FormulaDescription)))
%(%WriteTag('Instance', %FormulaInstance))
<Expressions>
#FOR(%FormulaExpression)
  <Expression>
    %(%WriteTag('Type', %GetStringValue(%FormulaExpressionType)))
    %(%WriteTag('Expression', %GetStringValue(%FormulaExpression)))
    %(%WriteTag('TrueLineNumber', %FormulaExpressionTrue))
    %(%WriteTag('FalseLineNumber', %FormulaExpressionFalse))
    %(%WriteTag('OfLineNumber', %FormulaExpressionOf))
    %(%WriteTag('AssignmentLineNumber', %FormulaExpressionCase))
  </Expression>
#ENDFOR
</Expressions>
#!-----------------------------------------------------------------------------
#GROUP(%GetProcedureTemplateInfo)
%(%WriteTag('Name', %GetStringValue(%ActiveTemplate)))
<Instances>
#FOR(%ActiveTemplateInstance)
  <Instance>
    %(%WriteTag('Type', %GetStringValue(%ActiveTemplateType)))
    %(%WriteTag('InstanceNumber', %ActiveTemplateInstance))
    %(%WriteTag('OwnerInstance', %ActiveTemplateOwnerInstance))
    %(%WriteTag('ParentInstance', %ActiveTemplateParentInstance))
    %(%WriteTag('PrimaryInstance', %ActiveTemplatePrimaryInstance))
    %(%WriteTag('Description', %GetStringValue(%ActiveTemplateInstanceDescription)))
#!  %(%HandleProcedureTemplate(%ActiveTemplate))                                            #! RA.2011.01.27
    %(%WriteTag('HandleProcedure', %HandleProcedureTemplate(%ActiveTemplate)))
  </Instance>
#ENDFOR
</Instances>
#!-----------------------------------------------------------------------------
#GROUP(%GetApplicationTemplateInfo)
%(%WriteTag('ApplicationTemplate', %GetStringValue(%ApplicationTemplate)))
<InstanceList>
#FOR(%ApplicationTemplateInstance)
  <Instance>
    %(%WriteTag('ApplicationTemplateInstance', %ApplicationTemplateInstance))
    %(%WriteTag('ApplicationTemplateInstanceDescription', %GetStringValue(%ApplicationTemplateInstanceDescription)))
    %(%WriteTag('ApplicationTemplateParentInstance', %ApplicationTemplateParentInstance))
    %(%WriteTag('ApplicationTemplatePrimaryInstance', %ApplicationTemplatePrimaryInstance))
#!  %(%HandleApplicationTemplate(%ApplicationTemplate))                                     #! RA.2011.01.27
    %(%WriteTag('HandleApplicationTemplate', %HandleApplicationTemplate(%ApplicationTemplate)))
  </Instance>
#ENDFOR
</InstanceList>
#!-----------------------------------------------------------------------------
#! RA.2022.09.04: First Pass
#GROUP(%GetApplicationInfo)
%(%WriteTag('Application', %GetStringValue(%Application)))
%(%WriteTag('ApplicationDebug', %GetBooleanValue(%ApplicationDebug)))
%(%WriteTag('ApplicationLocalLibrary', %GetBooleanValue(%ApplicationLocalLibrary)))
%(%WriteTag('ProjectTarget', %GetStringValue(%ProjectTarget)))
%(%WriteTag('Target32', %GetBooleanValue(%Target32)))
%(%WriteTag('DictionaryChanged', %GetBooleanValue(%DictionaryChanged)))
%(%WriteTag('RegistryChanged', %GetBooleanValue(%RegistryChanged)))
%(%WriteTag('ProgramDateCreated', %GetDateValue(%ProgramDateCreated)))
%(%WriteTag('ProgramDateChanged', %GetDateValue(%ProgramDateChanged)))
%(%WriteTag('ProgramDateChanged', %GetTimeValue(%ProgramDateChanged)))
%(%WriteTag('ProgramTimeChanged', %GetTimeValue(%ProgramTimeChanged)))
%(%WriteTag('FirstProcedure', %GetStringValue(%FirstProcedure)))
%(%WriteTag('HelpFile', %GetStringValue(%HelpFile)))
%(%WriteTag('ProgramExtension', %GetStringValue(%ProgramExtension)))
%(%WriteTag('DictionaryFile', %GetStringValue(%DictionaryFile)))
%(%WriteTag('Program', %GetStringValue(%Program)))
<GlobalData>
  %(%WriteTag('CreateLocalMap', %GetBooleanValue(%CreateLocalMap)))
  %(%WriteTag('QuickProcedure', %GetStringValue(%QuickProcedure)))
#! IGNORED  %(%WriteTag('', %GetStringValue(%EditProcedure)))
#! IGNORED  %(%WriteTag('', %GetStringValue(%EditFilename)))
  <GlobalVariableList>
#FOR(%GlobalData)
    <GlobalVariable>
      %(%WriteTag('GlobalData', %GetStringValue(%GlobalData)))
      %(%WriteTag('GlobalDataInDictionary', %GetBooleanValue(%GlobalDataInDictionary)))
      %(%WriteTag('GlobalDataStatement', %GetStringValue(%GlobalDataStatement)))
      %(%WriteTag('GlobalDataLast', %GetBooleanValue(%GlobalDataLast)))
      %(%WriteTag('GlobalDataLevel', %GlobalDataLevel))
      %(%WriteTag('GlobalDataUserOptions', %GetUserOptions(%GlobalDataUserOptions)))
    </GlobalVariable>
#ENDFOR
  </GlobalVariableList>
</GlobalData>
#!-----------------------------------------------------------------------------
#! RA.2022.09.04: First Pass
#GROUP(%GetModuleInfo)
%(%WriteTag('Module', %GetStringValue(%Module)))
%(%WriteTag('ModuleDescription', %GetStringValue(%ModuleDescription)))
%(%WriteTag('ModuleLanguage', %GetStringValue(%ModuleLanguage)))
%(%WriteTag('ModuleTemplate', %GetStringValue(%ModuleTemplate)))
%(%WriteTag('ModuleChanged', %GetBooleanValue(%ModuleChanged)))
%(%WriteTag('ModuleExternal', %GetBooleanValue(%ModuleExternal)))
%(%WriteTag('ModuleReadOnly', %GetBooleanValue(%ModuleReadOnly)))
%(%WriteTag('ModuleExtension', %GetStringValue(%ModuleExtension)))
%(%WriteTag('ModuleBase', %GetStringValue(%ModuleBase)))
%(%WriteTag('ModuleInclude', %GetStringValue(%ModuleInclude)))
#!-----------------------------------------------!
#! RA.2010.10.06 - Modified: See new tags bellow !
#!-----------------------------------------------!
#!<Procedures>
#!#FOR(%ModuleProcedure)
#!  %(%WriteTag('Procedure', %GetStringValue(%ModuleProcedure)))
#!#ENDFOR
#!</Procedures>
#!-----------------------------------------------!
<ModuleProcedureList>
#FOR(%ModuleProcedure)
  %(%WriteTag('ModuleProcedure', %GetStringValue(%ModuleProcedure)))
#ENDFOR
</ModuleProcedureList>
#!-----------------------------------------------!
#!-----------------------------------------------!
#! RA.2022.09.04: First Pass
<ModuleDataList>
#FOR(%ModuleData)
  <Variable>
    %(%WriteTag('ModuleData', %GetStringValue(%ModuleData)))
    %(%WriteTag('ModuleDataStatement', %GetStringValue(%ModuleDataStatement)))
    %(%WriteTag('ModuleDataUserOptions', %GetUserOptions(%ModuleDataUserOptions)))
  </Variable>
#ENDFOR
</ModuleDataList>
#!-----------------------------------------------------------------------------
#! RA.2022.09.04: First Pass
#GROUP(%GetProcedureInfo)
%(%WriteTag('ProcedureType', %GetStringValue(%ProcedureType)))
%(%WriteTag('ProcedureCategory', %GetStringValue(%ProcedureCategory)))
%(%WriteTag('Procedure', %GetStringValue(%Procedure)))
%(%WriteTag('ProcedureToDo', %GetBooleanValue(%ProcedureToDo)))
%(%WriteTag('ProcedureReturnType', %GetStringValue(%ProcedureReturnType)))
%(%WriteTag('ProcedureDateCreated', %GetDateValue(%ProcedureDateCreated)))
%(%WriteTag('ProcedureDateChanged', %GetDateValue(%ProcedureDateChanged)))
%(%WriteTag('ProcedureTimeCreated', %GetTimeValue(%ProcedureTimeCreated)))
%(%WriteTag('ProcedureTimeChanged', %GetTimeValue(%ProcedureTimeChanged)))
%(%WriteTag('ProcedureReadOnly', %GetBooleanValue(%ProcedureReadOnly)))
%(%WriteTag('ProcedureIsGlobal', %GetBooleanValue(%ProcedureIsGlobal)))
%(%WriteTag('ProcedureTemplate', %GetStringValue(%ProcedureTemplate)))
%(%WriteTag('ProcedureDescription', %GetStringValue(%ProcedureDescription)))
%(%WriteTag('ProcedureCategory', %GetStringValue(%ProcedureCategory)))
%(%WriteTag('ProcedureExported', %GetBooleanValue(%ProcedureExported)))
%(%WriteTag('ProcedureLongDescription', %GetStringValue(%ProcedureLongDescription)))
%(%WriteTag('ProcedureLanguage', %GetStringValue(%ProcedureLanguage)))
%(%WriteTag('Prototype', %GetStringValue(%Prototype)))
%(%WriteTag('Parameters', %GetStringValue(%Parameters)))
  #IF (%ProcedureReturnType)
%(%WriteTag('ProcedureReturnType', %GetStringValue(%ProcedureReturnType)))
  #ENDIF   
#!-----------------------------------------------!
#! RA.2010.10.06 - Modified: See new tags bellow !
#!-----------------------------------------------!
#!<Procedures>
#!#FOR(%ProcedureCalled)
#!  %(%WriteTag('Procedure', %GetStringValue(%ProcedureCalled)))
#!#ENDFOR
#!</Procedures>
#!-----------------------------------------------!
#! RA.2021.01.27 - Procedure Parameters          !
#!-----------------------------------------------!
#! RA.2022.09.04: First Pass
<ProcedureParameterList>
#IF(NOT VAREXISTS(%ParmNo))
  #DECLARE(%ParmNo,LONG)
#ENDIF  
#SET(%ParmNo,0)
#FOR(%ProcedureParameters)
  #SET(%ParmNo, %ParmNo + 1)
  <ProcedureParameter>
    #!%(%WriteTag('ParmNo', %GetStringValue(%ParmNo)))
    %(%WriteTag('ProcedureParameterType', %GetStringValue(%ProcedureParameterType)))
    %(%WriteTag('ProcedureParameterName', %GetStringValue(%ProcedureParameterName)))
    %(%WriteTag('ProcedureParameterOrigName', %GetStringValue(%ProcedureParameterOrigName)))
    %(%WriteTag('ProcedureParameterDefault', %GetBooleanValue(%ProcedureParameterDefault)))
    %(%WriteTag('ProcedureParameterOmitted', %GetBooleanValue(%ProcedureParameterOmitted)))
    %(%WriteTag('ProcedureParameterByReference', %GetBooleanValue(%ProcedureParameterByReference)))
    %(%WriteTag('ProcedureParameterConstant', %GetStringValue(%ProcedureParameterConstant)))
    %(%WriteTag('ProcedureParameterDIMs', %GetStringValue(%ProcedureParameterDIMs)))
  </ProcedureParameter>
#ENDFOR
</ProcedureParametersList>
#!-----------------------------------------------!
#! RA.2022.09.04: First Pass
<CalledProcedureList>
#FOR(%ProcedureCalled)
  %(%WriteTag('ProcedureCalled', %GetStringValue(%ProcedureCalled)))
#ENDFOR
</CalledProcedureList>
#!-----------------------------------------------!
#!-----------------------------------------------!
#! RA.2022.09.04: First Pass
<LocalDataList>
#FOR(%LocalData)
  <Variable>
    %(%WriteTag('LocalData', %GetStringValue(%LocalData)))
    %(%WriteTag('LocalDataStatement', %GetStringValue(%LocalDataStatement)))
    %(%WriteTag('LocalDataDescription', %GetStringValue(%LocalDataDescription)))
    %(%WriteTag('LocalDataHeader', %GetStringValue(%LocalDataHeader)))
    %(%WriteTag('LocalDataPicture', %GetStringValue(%LocalDataPicture)))
    %(%WriteTag('LocalDataJustType', %GetStringValue(%LocalDataJustType)))
    %(%WriteTag('LocalDataJustIndent', %LocalDataJustIndent))
    %(%WriteTag('LocalDataFormatWidth', %LocalDataFormatWidth))
    %(%WriteTag('LocalDataUserOptions', %GetUserOptions(%LocalDataUserOptions)))
  </Variable>
#ENDFOR
</LocalDataList>
#!-----------------------------------------------------------------------------
#! RA.2022.09.05: First Pass
#GROUP(%GetWindowInfo)
%(%WriteTag('Window', %GetStringValue(%Window)))
%(%WriteTag('WindowStatement', %GetStringValue(%WindowStatement)))
%(%WriteTag('MenuBarStatement', %GetStringValue(%MenuBarStatement)))
%(%WriteTag('ToolBarStatement', %GetStringValue(%ToolbarStatement)))
#! IGNORED  <Events>
#! IGNORED  #FOR(%WindowEvent)
#! IGNORED    %(%WriteTag('Event', %GetStringValue(%WindowEvent)))
#! IGNORED  #ENDFOR
#! IGNORED  </Events>
<WindowEventList>
#FOR(%WindowEvent)
  %(%WriteTag('WindowEvent', %GetStringValue(%WindowEvent)))
#ENDFOR
</WindowEventList>
<ControlList>
  #FOR(%Control)
  <Control>
    %(%WriteTag('ControlType', %GetStringValue(%ControlType)))
    %(%WriteTag('Control', %GetStringValue(%Control)))
    %(%WriteTag('ControlUse', %GetStringValue(%ControlUse)))
    %(%WriteTag('ControlTemplate', %GetStringValue(%ControlTemplate)))
    %(%WriteTag('ControlTool', %GetBooleanValue(%ControlTool)))
    %(%WriteTag('ControlParent', %GetStringValue(%ControlParent)))
    %(%WriteTag('ControlParentType', %GetStringValue(%ControlParentType)))
    %(%WriteTag('ControlParentTab', %GetStringValue(%ControlParentTab)))
    %(%WriteTag('ControlParameter', %GetStringValue(%ControlParameter)))
    %(%WriteTag('ControlHasIcon', %GetBooleanValue(%ControlHasIcon)))
    %(%WriteTag('ControlHasColor', %GetBooleanValue(%ControlHasColor)))
    %(%WriteTag('ControlHasStyle', %GetBooleanValue(%ControlHasStyle)))
    %(%WriteTag('ControlHasTip', %GetBooleanValue(%ControlHasTip)))
    %(%WriteTag('ControlHasTree', %GetBooleanValue(%ControlHasTree)))
    %(%WriteTag('ControlDefaultWidth', %ControlDefaultWidth))
    %(%WriteTag('ControlDefaultHeight', %ControlDefaultHeight))
    %(%WriteTag('ControlMenu', %GetBooleanValue(%ControlMenu)))
    %(%WriteTag('ControlIndent', %ControlIndent))
    %(%WriteTag('ControlInstance', %ControlInstance))
    %(%WriteTag('ControlOriginal', %GetStringValue(%ControlOriginal)))
    %(%WriteTag('ControlFrom', %GetStringValue(%ControlFrom)))
#!!----------BANANA
#!    <Events>
#!    #FOR(%ControlEvent)
#!      %(%WriteTag('Event', %GetStringValue(%ControlEvent)))
#!    #ENDFOR
#!    </Events>
#!    %(%WriteTag('', %GetStringValue(%ControlStatement)))
#!!----------BANANA
#!----------BANANA
    <EventList>
    #FOR(%ControlEvent)
      %(%WriteTag('ControlEvent', %GetStringValue(%ControlEvent)))
    #ENDFOR
    </EventList>
    %(%WriteTag('ControlStatement', %GetStringValue(%ControlStatement)))
#!----------BANANA
    %(%WriteTag('ControlUnsplitStatement', %GetStringValue(%ControlUnsplitStatement)))
    %(%WriteTag('ControlToolBar', %GetStringValue(%ControlToolBar)))
    %(%WriteTag('ControlMenuBar', %GetStringValue(%ControlMenuBar)))
#!!----------BANANA
#!    <Keycodes>
#!    #FOR(%ControlAlert)
#!      %(%WriteTag('Keycode', %GetStringValue(%ControlAlert)))
#!    #ENDFOR
#!    </Keycodes>
#!!----------BANANA
#!!----------BANANA
    <Keycodes>
    #FOR(%ControlAlert)
      %(%WriteTag('ControlAlert', %GetStringValue(%ControlAlert)))
    #ENDFOR
    </Keycodes>
#!!----------BANANA
    <ControlFieldList>
    #FOR(%ControlField)
      <Field>
        %(%WriteTag('ControlField', %GetStringValue(%ControlField)))
        %(%WriteTag('ControlFieldHasIcon', %GetBooleanValue(%ControlFieldHasIcon)))
        %(%WriteTag('ControlFieldHasColor', %GetBooleanValue(%ControlFieldHasColor)))
        %(%WriteTag('ControlFieldHasTree', %GetBooleanValue(%ControlFieldHasTree)))
        %(%WriteTag('ControlFieldHasLocator', %GetBooleanValue(%ControlFieldHasLocator)))
        %(%WriteTag('ControlFieldHasTip', %GetBooleanValue(%ControlFieldHasTip)))
        %(%WriteTag('ControlFieldDefaultTip', %GetStringValue(%ControlFieldDefaultTip)))
        %(%WriteTag('ControlFieldPicture', %GetStringValue(%ControlFieldPicture)))
        %(%WriteTag('ControlFieldHeader', %GetStringValue(%ControlFieldHeader)))
        %(%WriteTag('ControlFieldFormat', %GetStringValue(%ControlFieldFormat)))
      </Field>
    #ENDFOR
    </ControlFieldList>
  </Control>
  #ENDFOR
</ControlList>
#!-----------------------------------------------------------------------------
#GROUP(%GetReportInfo)
%(%WriteTag('Report', %GetStringValue(%Report)))
%(%WriteTag('ReportStatement', %GetStringValue(%ReportStatement)))
<ReportControlList>
  #FOR(%ReportControl)
  <Control>
    %(%WriteTag('ReportControlType', %GetStringValue(%ReportControlType)))
    %(%WriteTag('ReportControl', %GetStringValue(%ReportControl)))
    %(%WriteTag('ReportControlUse', %GetStringValue(%ReportControlUse)))
    %(%WriteTag('ReportControlStatement', %GetStringValue(%ReportControlStatement)))
    %(%WriteTag('ReportControlTemplate', %GetStringValue(%ReportControlTemplate)))
    %(%WriteTag('ReportControlIndent', %GetStringValue(%ReportControlIndent)))
    %(%WriteTag('ReportControlInstance', %GetStringValue(%ReportControlInstance)))
    %(%WriteTag('ReportControlOriginal', %GetStringValue(%ReportControlOriginal)))
    #! ?  %(%WriteTag('', %GetStringValue(%ReportControlLabel)))
    <FieldList>
    #FOR(%ReportControlField)
      %(%WriteTag('ReportControlField', %GetStringValue(%ReportControlField)))
    #ENDFOR
    </FieldList>
  </Control>
  #ENDFOR
</ReportControlList>
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#UTILITY(XMLDOC_DCT2XML, '2010.10.05 - Dictionary to XML')
#! TODO
#!   Normalize whatever needs to be normalized
#!   'Options' Stuff
#!   File      - Trigger Stuff
#!   Key       - KeyOrder Stuff
#!   Field     - Choices Stuff
#!
#PROMPT('Output File', SAVEDIALOG('Output File', '*.*')), %pOutputFile, REQ
#PROMPT('Dictionary Info', CHECK), %pExportDictionaryInfo, DEFAULT(%True)
#PROMPT('File Info', CHECK), %pExportFileInfo, DEFAULT(%True)
#PROMPT('Key Info', CHECK), %pExportKeyInfo, DEFAULT(%True)
#PROMPT('Field Info', CHECK), %pExportFieldInfo, DEFAULT(%True)
#PROMPT('Relation Info', CHECK), %pExportRelationInfo, DEFAULT(%True)
#PROMPT('File Driver Info', CHECK), %pFileDriverInfo
#INSERT(%Notice)
#!
#PREPARE
  #DECLARE(%pDictionaryFile)
  #SET(%pDictionaryFile, %DictionaryFile)
  #CALL(%ReplaceSubString, %pDictionaryFile, '.', '_')
  #SET(%pOutputFile, %pDictionaryFile & '.xml')
  #SET(%pDateModified, DEFORMAT('Oct 5, 2010', @D4))
#ENDPREPARE
#!
#DECLARE(%Groups), MULTI, UNIQUE
#EQUATE(%nFiles, ITEMS(%File))
#DECLARE(%nFile)
#SET(%nFile, 0)
#CREATE(%pOutputFile)
<?xml version="1.0"?>
<Dictionary>
  #IF(%pExportDictionaryInfo)
  #INSERT(%GetDictionaryInfo)
  #ENDIF
  <Files>
  #FOR(%File)
    #SET(%nFile, %nFile + 1)
    #MESSAGE('Processing ' & %nFile & ' of ' & %nFiles & ' (' & %File & ')', 1)
    <File>
      %(%WriteTag('Type', %GetStringValue(%FileType)))
      %(%WriteTag('Label', %GetStringValue(%File)))
    #IF(%pExportFileInfo)
      #INSERT(%GetFileInfo)
    #ENDIF
    #IF(%pExportKeyInfo)
      <Keys>
      #FOR(%Key)
        <Key>
          #INSERT(%GetKeyInfo)
        </Key>
      #ENDFOR
      </Keys>
    #ENDIF
    #IF(%pExportFieldInfo)
      <Fields>
      #FOR(%Field)
        #IF(NOT %FieldID)
          #DELETE(%Groups)
          #IF(ITEMS(%Groups))
            #SELECT(%Groups, ITEMS(%Groups))
          #ENDIF
        #ELSE
        <Field>
          #INSERT(%GetFieldInfo)
        </Field>
          #IF(%FieldType = 'GROUP')
            #ADD(%Groups, %Field)
          #ENDIF
        #ENDIF
      #ENDFOR
      </Fields>
    #ENDIF
    #IF(%pExportRelationInfo)
      <Relations>
      #FOR(%Relation)
        <Relation>
          #INSERT(%GetRelationInfo)
        </Relation>
      #ENDFOR
      </Relations>
    #ENDIF
    </File>
  #ENDFOR
  </Files>
  #IF(%pFileDriverInfo)
  <FileDrivers>
    #FOR(%Driver)
      <FileDriver>
        #INSERT(%GetFileDriverInfo)
      </FileDriver>
    #ENDFOR
  </FileDrivers>
  #ENDIF
</Dictionary>
#CLOSE(%pOutputFile)
#RUN('NOTEPAD.EXE "' & %pOutputFile & '"')
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#GROUP(%GetDictionaryInfo)
%(%WriteTag('DictionaryFile', %GetStringValue(%DictionaryFile)))
%(%WriteTag('DictionaryQuickOptions', %GetQuickOptions(%DictionaryQuickOptions)))
%(%WriteTag('DictionaryUserOptions', %GetUserOptions(%DictionaryUserOptions)))
%(%WriteTag('DictionaryToolOptions', %GetToolOptions(%DictionaryToolOptions)))
%(%WriteTag('DictionaryDescription', %GetStringValue(%DictionaryDescription)))
%(%WriteTag('DictionaryVersion', %GetVersionInfo(%DictionaryVersion)))
%(%WriteTag('DictionaryTimeCreated', %GetTimeValue(%DictionaryTimeCreated)))
%(%WriteTag('DictionaryDateCreated', %GetDateValue(%DictionaryDateCreated)))
%(%WriteTag('DictionaryTimeChanged', %GetTimeValue(%DictionaryTimeChanged)))
%(%WriteTag('DictionaryDateChanged', %GetDateValue(%DictionaryDateChanged)))
#!-----------------------------------------------------------------------------
#GROUP(%GetFileInfo)
#! RA.2010.10.06 - Moved 'Driver' to the front of this group.
#! RA.2010.10.06 - Moved 'Type' to where this is called to go with the label.
%(%WriteTag('FileDriver', %GetStringValue(%FileDriver)))
%(%WriteTag('FileType', %GetStringValue(%FileType)))
%(%WriteTag('File32BitOnly', %GetBooleanValue(%File32BitOnly)))
%(%WriteTag('FileBindable', %GetBooleanValue(%FileBindable)))
%(%WriteTag('FileCreate', %GetBooleanValue(%FileCreate)))
%(%WriteTag('FileDescription', %GetStringValue(%FileDescription)))
%(%WriteTag('FileDriverParameter', %GetStringValue(%FileDriverParameter)))
%(%WriteTag('FileEncrypt', %GetBooleanValue(%FileEncrypt)))
%(%WriteTag('FileExternal', %GetBooleanValue(%FileExternal)))
%(%WriteTag('FileExternalModule', %GetStringValue(%FileExternalModule)))
%(%WriteTag('FileIdent', %FileIdent))
%(%WriteTag('FileLastModified', %FileLastModified))
%(%WriteTag('FileLongDesc', %GetStringValue(%FileLongDesc)))
%(%WriteTag('FileName', %GetStringValue(%FileName)))
%(%WriteTag('FileOEM', %GetBooleanValue(%FileOEM)))
%(%WriteTag('FileOwner', %GetStringValue(%FileOwner)))
%(%WriteTag('FilePrefix', %GetStringValue(%FilePrefix)))
%(%WriteTag('FilePrimaryKey', %GetStringValue(%FilePrimaryKey)))
%(%WriteTag('FileQuickOptions', %GetQuickOptions(%FileQuickOptions)))
%(%WriteTag('FileReclaim', %GetBooleanValue(%FileReclaim)))
#! IGNORED  %(%WriteTag('Statement', %GetStringValue(%FileStatement)))
#! IGNORED  %(%WriteTag('Struct', %GetStringValue(%FileStruct)))
#! IGNORED  %(%WriteTag('StructEnd', %GetStringValue(%FileStructEnd)))
#! IGNORED  %(%WriteTag('StructRec', %GetStringValue(%FileStructRec)))
#! IGNORED  %(%WriteTag('StructRecEnd', %GetStringValue(%FileStructRecEnd)))
%(%WriteTag('FileStatement', %GetStringValue(%FileStatement)))
%(%WriteTag('FileStruct', %GetStringValue(%FileStruct)))
%(%WriteTag('FileStructEnd', %GetStringValue(%FileStructEnd)))
%(%WriteTag('FileStructRec', %GetStringValue(%FileStructRec)))
%(%WriteTag('FileStructRecEnd', %GetStringValue(%FileStructRecEnd)))
%(%WriteTag('FileThreaded', %GetBooleanValue(%FileThreaded)))
#!  %(%WriteTag('TriggerBeforeInsert', %FileTriggerBeforeInsert))
#!  %(%WriteTag('TriggerAfterInsert', %FileTriggerAfterInsert))
#!  %(%WriteTag('TriggerBeforeUpdate', %FileTriggerBeforeUpdate))
#!  %(%WriteTag('TriggerAfterUpdate', %FileTriggerAfterUpdate))
#!  %(%WriteTag('TriggerBeforeDelete', %FileTriggerBeforeDelete))
#!  %(%WriteTag('TriggerAfterDelete', %FileTriggerAfterDelete))
#!  %(%WriteTag('TriggerDataInitialValue', %FileTriggerDataInitialValue))
%(%WriteTag('FileUserOptions', %GetUserOptions(%FileUserOptions)))
%(%WriteTag('AliasFile', %GetStringValue(%AliasFile)))
#!-----------------------------------------------------------------------------
#GROUP(%GetKeyInfo)
  #IF(%True)
%(%WriteTag('KeyIndex', %GetStringValue(%KeyIndex)))
%(%WriteTag('Key', %GetStringValue(%Key)))
%(%WriteTag('KeyIdent', %KeyIdent))
%(%WriteTag('KeyDescription', %GetStringValue(%KeyDescription)))
%(%WriteTag('KeyLongDesc', %GetStringValue(%KeyLongDesc)))
%(%WriteTag('KeyFile', %GetStringValue(%KeyFile)))
%(%WriteTag('KeyID', %GetStringValue(%KeyID)))
%(%WriteTag('KeyName', %GetStringValue(%KeyName)))
%(%WriteTag('KeyAuto', %GetStringValue(%KeyAuto)))
%(%WriteTag('KeyDuplicate', %GetBooleanValue(%KeyDuplicate)))
%(%WriteTag('KeyExcludeNulls', %GetBooleanValue(CHOOSE(%KeyExcludeNulls = '1', '', '1'))))
%(%WriteTag('KeyNoCase', %GetBooleanValue(CHOOSE(%KeyNoCase = '1', '', '1'))))
%(%WriteTag('KeyPrimary', %GetBooleanValue(%KeyPrimary)))
#! IGNORED    %(%WriteTag('Struct', %GetStringValue(%KeyStruct)))
#! IGNORED    %(%WriteTag('Statement', %GetStringValue(%KeyStatement)))
%(%WriteTag('KeyStruct', %GetStringValue(%KeyStruct)))
%(%WriteTag('KeyStatement', %GetStringValue(%KeyStatement)))
<Fields>
#FOR(%KeyField)
  <Field>
    %(%WriteTag('KeyField', %GetStringValue(%KeyField)))
    %(%WriteTag('KeyFieldSequence', %GetStringValue(%KeyFieldSequence)))
  </Field>
#ENDFOR
</Fields>
%(%WriteTag('KeyQuickOptions', %GetQuickOptions(%KeyQuickOptions)))
%(%WriteTag('KeyUserOptions', %GetUserOptions(%KeyUserOptions)))
%(%WriteTag('KeyToolOptions', %GetToolOptions(%KeyToolOptions)))
  #ELSE
%(%WriteTag('KeyOrderIndex', %GetStringValue(%KeyOrderIndex)))
%(%WriteTag('KeyOrder', %GetStringValue(%KeyOrder)))
%(%WriteTag('KeyOrderIdent', %KeyOrderIdent))
%(%WriteTag('KeyOrderDescription', %GetStringValue(%KeyOrderDescription)))
%(%WriteTag('KeyOrderLongDesc', %GetStringValue(%KeyOrderLongDesc)))
%(%WriteTag('KeyOrderFile', %GetStringValue(%KeyOrderFile)))
%(%WriteTag('KeyOrderID', %GetStringValue(%KeyOrderID)))
%(%WriteTag('KeyOrderName', %GetStringValue(%KeyOrderName)))
%(%WriteTag('KeyOrderAuto', %GetStringValue(%KeyOrderAuto)))
%(%WriteTag('KeyOrderDuplicate', %GetBooleanValue(%KeyOrderDuplicate)))
%(%WriteTag('KeyOrderDuplicate', %GetBooleanValue(%KeyOrderDuplicate)))
%(%WriteTag('KeyOrderNoCase', %GetBooleanValue(%KeyOrderNoCase)))
%(%WriteTag('KeyOrderPrimary', %GetBooleanValue(%KeyOrderPrimary)))
#! IGNORED    %(%WriteTag('Struct', %GetStringValue(%KeyOrderStruct)))
#! IGNORED    %(%WriteTag('Statement', %GetStringValue(%KeyOrderStatement)))
%(%WriteTag('KeyOrderStruct', %GetStringValue(%KeyOrderStruct)))
%(%WriteTag('KeyOrderStatement', %GetStringValue(%KeyOrderStatement)))
%(%WriteTag('KeyOrderQuickOptions', %GetQuickOptions(%KeyOrderQuickOptions)))
%(%WriteTag('KeyOrderUserOptions', %GetUserOptions(%KeyOrderUserOptions)))
%(%WriteTag('KeyOrderToolOptions', %GetToolOptions(%KeyOrderToolOptions)))
  #ENDIF
#!-----------------------------------------------------------------------------
#GROUP(%GetFieldInfo)
%(%WriteTag('FieldType', %GetStringValue(%FieldType)))
%(%WriteTag('Index', INSTANCE(%Field)))
%(%WriteTag('Field', %GetStringValue(%Field)))
%(%WriteTag('Groups', %GetStringValue(%Groups)))
%(%WriteTag('FieldIdent', %FieldIdent))
%(%WriteTag('FieldDescription', %GetStringValue(%FieldDescription)))
%(%WriteTag('FieldLongDesc', %GetStringValue(%FieldLongDesc)))
%(%WriteTag('FieldFile', %GetStringValue(%FieldFile)))
%(%WriteTag('FieldID', %GetStringValue(%FieldID)))
%(%WriteTag('FieldDisplayPicture', %GetStringValue(%FieldDisplayPicture)))
#! IGNORED  %(%WriteTag('RecordPicture', %GetStringValue(%FieldRecordPicture)))
%(%WriteTag('FieldRecordPicture', %GetStringValue(%FieldRecordPicture)))
%(%WriteTag('FieldDimension1', %FieldDimension1))
%(%WriteTag('FieldDimension2', %FieldDimension2))
%(%WriteTag('FieldDimension3', %FieldDimension3))
%(%WriteTag('FieldDimension4', %FieldDimension4))
%(%WriteTag('FieldHelpID', %GetStringValue(%FieldHelpID)))
%(%WriteTag('FieldName', %GetStringValue(%FieldName)))
%(%WriteTag('FieldRangeLow', %GetStringValue(%FieldRangeLow)))
%(%WriteTag('FieldRangeHigh', %GetStringValue(%FieldRangeHigh)))
%(%WriteTag('FieldPlaces', %FieldPlaces))
%(%WriteTag('FieldMemoSize', %FieldMemoSize))
%(%WriteTag('FieldMemoImage', %GetBooleanValue(%FieldMemoImage)))
%(%WriteTag('FieldInitial', %GetStringValue(%FieldInitial)))
%(%WriteTag('FieldLookup', %GetStringValue(%FieldLookup)))
%(%WriteTag('FieldOver', %GetStringValue(EXTRACT(%FieldStruct, 'OVER', 1))))
#! IGNORED  %(%WriteTag('Struct', %GetStringValue(%FieldStruct)))
#! IGNORED  %(%WriteTag('Statement', %GetStringValue(%FieldStatement)))
%(%WriteTag('FieldStruct', %GetStringValue(%FieldStruct)))
%(%WriteTag('FieldStatement', %GetStringValue(%FieldStatement)))
%(%WriteTag('FieldHeader', %GetStringValue(%FieldHeader)))
#! IGNORED  %(%WriteTag('Picture', %GetStringValue(%FieldPicture)))
%(%WriteTag('FieldPicture', %GetStringValue(%FieldPicture)))
%(%WriteTag('FieldJustType', %GetStringValue(%FieldJustType)))
%(%WriteTag('FieldJustIndent', %FieldJustIndent))
%(%WriteTag('FieldFormatWidth', %FieldFormatWidth))
<ScreenControls>
#FOR(%FieldScreenControl)
  <ScreenControl>
    %(%WriteTag('FieldScreenControl', %GetStringValue(%FieldScreenControl)))
#! RA.2020.02.05: ??? SV broke it!
#!    %(%WriteTag('Width', %FieldScreenControlWidth))
#!    %(%WriteTag('Height', %FieldScreenControlHeight))
  </ScreenControl>
#ENDFOR
</ScreenControls>
<ReportControls>
#FOR(%FieldScreenControl)
  <ReportControl>
    %(%WriteTag('FieldReportControl', %GetStringValue(%FieldReportControl)))
#! RA.2020.02.05: ??? SV broke it!
#!    %(%WriteTag('Width', %FieldReportControlWidth))
#!    %(%WriteTag('Height', %FieldReportControlHeight))
  </ReportControl>
#ENDFOR
</ReportControls>
%(%WriteTag('FieldValidation', %GetStringValue(%FieldValidation)))
#!  %(%WriteTag('', %FieldChoices))
#!  %(%WriteTag('', %FieldValues))
%(%WriteTag('FieldChoices', %FieldChoices))
%(%WriteTag('FieldValues', %FieldValues))
%(%WriteTag('TrueValue', %GetStringValue(%FieldTrueValue)))
%(%WriteTag('FalseValue', %GetStringValue(%FieldFalseValue)))
#!-----
#!  %(%WriteTag('', %FieldDisplayChoices))
#!-----
%(%WriteTag('FieldQuickOptions', %GetQuickOptions(%FieldQuickOptions)))
%(%WriteTag('FieldUserOptions', %GetUserOptions(%FieldUserOptions)))
%(%WriteTag('FieldToolOptions', %GetToolOptions(%FieldToolOptions)))
#!-----------------------------------------------------------------------------
#GROUP(%GetRelationInfo)
%(%WriteTag('FileRelationType', %GetStringValue(%FileRelationType)))
%(%WriteTag('Relation', %GetStringValue(%Relation)))
%(%WriteTag('RelationPrefix', %GetStringValue(%RelationPrefix)))
%(%WriteTag('RelationAlias', %GetStringValue(%RelationAlias)))
%(%WriteTag('RelationKey', %GetStringValue(%RelationKey)))
%(%WriteTag('RelationPrimaryKey', %GetStringValue(%RelationPrimaryKey)))
%(%WriteTag('FileKey', %GetStringValue(%FileKey)))
%(%WriteTag('RelationDriver', %GetStringValue(%RelationDriver)))
%(%WriteTag('RelationConstraintDelete', %GetStringValue(%RelationConstraintDelete)))
%(%WriteTag('RelationConstraintUpdate', %GetStringValue(%RelationConstraintUpdate)))
#! IGNORED  <RelationKeyFields>
#! IGNORED  #FOR(%RelationKeyField)
#! IGNORED    <RelationKeyField>
#! IGNORED      %(%WriteTag('Field', %RelationKeyField))
#! IGNORED      %(%WriteTag('FieldLink', %RelationKeyFieldLink))
#! IGNORED    </RelationKeyField>
#! IGNORED  #ENDFOR
#! IGNORED  </RelationKeyFields>
  <RelationKeyFieldList>
  #FOR(%RelationKeyField)
    <RelationKeyField>
      %(%WriteTag('RelationKeyField', %RelationKeyField))
      %(%WriteTag('RelationKeyFieldLink', %RelationKeyFieldLink))
    </RelationKeyField>
  #ENDFOR
  </RelationKeyFieldList>
<FileKeyFields>
#FOR(%RelationKeyField)
  <FileKeyField>
    %(%WriteTag('RelationKeyField', %GetStringValue(%RelationKeyField)))
    %(%WriteTag('RelationKeyFieldLink', %GetStringValue(%RelationKeyFieldLink)))
  </FileKeyField>
#ENDFOR
</FileKeyFields>
%(%WriteTag('RelationQuickOptions', %GetQuickOptions(%RelationQuickOptions)))
%(%WriteTag('RelationUserOptions', %GetUserOptions(%RelationUserOptions)))
%(%WriteTag('RelationToolOptions', %GetToolOptions(%RelationToolOptions)))
#!-----------------------------------------------------------------------------
#GROUP(%GetFileDriverInfo)
%(%WriteTag('Driver', %GetStringValue(%Driver)))
%(%WriteTag('DriverDLL', %GetStringValue(%DriverDLL)))
%(%WriteTag('DriverLIB', %GetStringValue(%DriverLIB)))
%(%WriteTag('DriverDescription', %GetStringValue(%DriverDescription)))
%(%WriteTag('DriverCreate', %GetBooleanValue(%DriverCreate)))
%(%WriteTag('DriverOwner', %GetBooleanValue(%DriverOwner)))
%(%WriteTag('DriverEncrypt', %GetBooleanValue(%DriverEncrypt)))
%(%WriteTag('DriverReclaim', %GetBooleanValue(%DriverReclaim)))
%(%WriteTag('DriverMaxKeys', %DriverMaxKeys))
%(%WriteTag('DriverUniqueKey', %GetBooleanValue(%DriverUniqueKey)))
%(%WriteTag('DriverRequired', %GetBooleanValue(%DriverRequired)))
%(%WriteTag('DriverMemo', %GetBooleanValue(%DriverMemo)))
%(%WriteTag('DriverBinMemo', %GetBooleanValue(%DriverBinMemo)))
%(%WriteTag('DriverSQL', %GetBooleanValue(%DriverSQL)))
%(%WriteTag('DriverOEM', %GetBooleanValue(%DriverOEM)))
<DriverTypeList>
#FOR(%DriverType)
  %(%WriteTag('DriverType', %GetStringValue(%DriverType)))
#ENDFOR
</DriverTypeList>
<DriverOpcodeList>
#FOR(%DriverOpcode)
  %(%WriteTag('DriverOpcode', %GetStringValue(%DriverOpcode)))
#ENDFOR
</DriverOpcodeList>
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#GROUP(%XMLDOCMAINEND)
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
#!-----------------------------------------------------------------------------
