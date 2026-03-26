#Include 'Protheus.ch'
#Include 'FWMVCStandard.ch'
#Include 'RestFul.ch'

/*/ GenTarSubTar.prw
Rotina de Gerenciamento de Tarefas e Subtarefas (MVC + REST)
Autor   : Mauricio Choiti Aoki
Data    : 26/03/2026
Objetivo: Desafio Fullstack Angular Advpl - Módulo Jurídico
/*/
User Function GenTarSubTar() 
    Local oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZG")
    oBrowse:SetDescription("Gerenciador de Tarefas")
    oBrowse:Activate()
Return NIL

Static Function MenuDef()
    Local aRotina := {}
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.GenTarSubTar' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.GenTarSubTar' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.GenTarSubTar' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.GenTarSubTar' OPERATION 5 ACCESS 0
Return aRotina

Static Function ModelDef()
    Local oModel
    Local oStruZZG := FWFormStruct(1, "ZZG")
    Local oStruZZH := FWFormStruct(1, "ZZH")

    oModel := MPFormModel():New("GenTarSubTarM", , {|oMdl| ValidSavy(oMdl)})
    oModel:AddFields("MASTERZZG", , oStruZZG)
    oModel:AddGrid("DETAILZZH", "MASTERZZG", oStruZZH)
    
    oModel:SetRelation("DETAILZZH", {{"ZZH_FILIAL", "xFilial('ZZH')"}, {"ZZH_CODTAR", "ZZG_CODIGO"}}, ZZH->(IndexKey(1)))
    oModel:GetModel("DETAILZZH"):SetOptional(.T.)

    // Preenchimento automático de campos de auditoria e código
    oModel:GetModel("MASTERZZG"):GetStruct():SetProperty("ZZG_CODIGO", MODEL_FIELD_WHEN, {|| .F.}) // Bloqueia edição
    oModel:GetModel("MASTERZZG"):GetStruct():SetProperty("ZZG_USUINC", MODEL_FIELD_INIT, {|| __cUserId})
    oModel:GetModel("MASTERZZG"):GetStruct():SetProperty("ZZG_DTINC",  MODEL_FIELD_INIT, {|| dDataBase})
    
    Return oModel

Static Function ViewDef()
    Local oView := FWFormView():New()
    oView:SetModel(FWLoadModel("GenTarSubTar"))
    oView:AddField("VIEW_ZZG", FWFormStruct(2, "ZZG"), "MASTERZZG")
    oView:AddGrid("VIEW_ZZH", FWFormStruct(2, "ZZH"), "DETAILZZH")
    oView:CreateHorizontalBox("CABEC", 35)
    oView:CreateHorizontalBox("GRID", 65)
    oView:SetOwnerView("VIEW_ZZG", "CABEC")
    oView:SetOwnerView("VIEW_ZZH", "GRID")
    Return oView

Static Function ValidSavy(oModel)
    Local lRet      := .T.
    Local oMdlZZG   := oModel:GetModel("MASTERZZG")
    Local oMdlZZH   := oModel:GetModel("DETAILZZH")
    Local nStatus   := oMdlZZG:GetValue("ZZG_SITUAC")
    Local dDtInc    := oMdlZZG:GetValue("ZZG_DTINC")
    Local dDtConc   := oMdlZZG:GetValue("ZZG_DTCONC")
    Local nX, nTot := 0, nConc := 0
    
    // Regra: Data de Conclusão >= Data de Inclusão
    If !Empty(dDtConc) .And. dDtConc < dDtInc
        Help("",1,"DATA_ERR",,"A data de conclusao nao pode ser menor que a de inclusao.",1,0)
        Return .F.
    EndIf

    // Regra: Validar conclusão e Automar status
    For nX := 1 To oMdlZZH:Length()
        oMdlZZH:GoLine(nX)
        If !oMdlZZH:IsDeleted()
            nTot++
            If oMdlZZH:GetValue("ZZH_STATUS") == "3"
                nConc++
            EndIf
        EndIf
    Next

    // Bloqueio: Não conclui pai se houver filho pendente
    If nStatus == "3" .And. nConc < nTot
        Help("",1,"SUB_PEND",,"Existem subtarefas pendentes. Nao e possivel concluir a tarefa.",1,0)
        Return .F.
    EndIf

    // Automação solicitada: Se todas concluídas -> Pai concluída
    If nTot > 0 .And. nConc == nTot
        oMdlZZG:LoadValue("ZZG_SITUAC", "3")
        If Empty(dDtConc); oMdlZZG:LoadValue("ZZG_DTCONC", dDataBase); EndIf
    EndIf

    Return lRet

/* API REST */
WSRESTFUL tasks DESCRIPTION "API CRUD de Tarefas"
    WSDATA id AS STRING
    WSMETHOD GET DESCRIPTION "Listar" WSSYNTAX "/tasks/||/tasks/{id}"
    WSMETHOD POST DESCRIPTION "Incluir" WSSYNTAX "/tasks"
    WSMETHOD PUT DESCRIPTION "Alterar" WSSYNTAX "/tasks/{id}"
    WSMETHOD DELETE DESCRIPTION "Excluir" WSSYNTAX "/tasks/{id}"
END WSRESTFUL

WSMETHOD GET WSSERVICE tasks
    Local oRest := FWRestModel():New()
    oRest:SetModelID("GenTarSubTar")
    oRest:Activate()
    If !Empty(Self:id); oRest:SetID(Self:id); EndIf
    Self:SetResponse(oRest:Get())
Return .T.

WSMETHOD POST WSSERVICE tasks
    Local oRest := FWRestModel():New()
    oRest:SetModelID("GenTarSubTar")
    oRest:Activate()
    If oRest:Post(Self:GetContent()); Self:SetResponse(oRest:GetResponse())
    Else; Self:SetRestError(400, oRest:GetError()); EndIf
Return .T.

WSMETHOD PUT WSSERVICE tasks
    Local oRest := FWRestModel():New()
    oRest:SetModelID("GenTarSubTar")
    oRest:SetID(Self:id)
    oRest:Activate()
    If oRest:Put(Self:GetContent()); Self:SetResponse(oRest:GetResponse())
    Else; Self:SetRestError(400, oRest:GetError()); EndIf
Return .T.

WSMETHOD DELETE WSSERVICE tasks
    Local oRest := FWRestModel():New()
    oRest:SetModelID("GenTarSubTar")
    oRest:SetID(Self:id)
    oRest:Activate()
    If oRest:Delete(); Self:SetResponse(oRest:GetResponse())
    Else; Self:SetRestError(400, oRest:GetError()); EndIf
Return .T.
