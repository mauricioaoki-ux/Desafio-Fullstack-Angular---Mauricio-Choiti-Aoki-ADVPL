/*
Componente tasks.component.ts
Autor   : Mauricio Choiti Aoki
Data    : 26/03/2026
Objetivo: Desafio Fullstack Angular Advpl - Módulo Jurídico
*/

import { Component } from '@angular/core';
import { PoPageDynamicTableActions, PoPageDynamicTableField } from '@po-ui/ng-templates';

@Component({
  selector: 'app-tasks',
  template: `
    <po-page-dynamic-table
      p-title="Gerenciamento de Tarefas - PO-UI"
      [p-service-api]="apiService"
      [p-fields]="fields"
      [p-actions]="actions">
    </po-page-dynamic-table>
  `
})
export class TasksComponent {
  // Ajustar porta conforme AppServer.ini (ex: 8080)
  readonly apiService = 'http://localhost:8080/rest/tasks';

  readonly fields: Array<PoPageDynamicTableField> = [
    { property: 'ZZG_CODIGO', label: 'Cód.', key: true, width: '5%' },
    { property: 'ZZG_TITULO', label: 'Título', filter: true, width: '25%' },
    { property: 'ZZG_DESCRI', label: 'Descrição', filter: true, gridNoVisible: true },
    { property: 'ZZG_SITUAC', label: 'Situação', type: 'label', width: '15%', labels: [
      { value: '1', label: 'Pendente', color: 'color-01' },
      { value: '2', label: 'Andamento', color: 'color-08' },
      { value: '3', label: 'Concluída', color: 'color-11' },
      { value: '4', label: 'Cancelada', color: 'color-07' }
    ]},
    { property: 'ZZG_DTINC', label: 'Inclusão', type: 'date', width: '10%' },
    { property: 'ZZG_DTCONC', label: 'Conclusão', type: 'date', width: '10%' }
  ];

  readonly actions: PoPageDynamicTableActions = {
    new: '/tasks/new',
    edit: '/tasks/edit/:id',
    remove: true
  };
}
