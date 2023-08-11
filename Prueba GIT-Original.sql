procedure guardar_adjuntos(i_solicitud in number, i_attachment_name in varchar2, i_attachment_type in number) as
 l_file apex_application_temp_files%rowtype;
 l_id_archivo number;
 l_conteo number;
begin
 select count(*) into l_conteo from snw_fonviv_credito.solicitud_documento where id_solicitud = i_solicitud and tipo = i_attachment_type;
 -- Primero verificamos si el archivo es nulo, es decir, no se cargo o no aplica.
 if i_attachment_name is null then 
 if l_conteo > 0 then
 select id_archivo into l_id_archivo from snw_fonviv_credito.solicitud_documento where id_solicitud = i_solicitud and tipo = i_attachment_type;
 -- Eliminamos el registro del archivo en snw_fonviv 
 delete snw_fonviv_credito.solicitud_documento where id_solicitud = i_solicitud and tipo = i_attachment_type;
 -- Eliminamos archivo de snw_files
 snw_fonviv_utils.files_pck.delete_file(l_id_archivo);
 end if;
 else
 select * into l_file from apex_application_temp_files where name = i_attachment_name;
 l_id_archivo := snw_fonviv_utils.files_pck.save_file(l_file,null);
 if l_conteo > 0 then
 update snw_fonviv_credito.solicitud_documento set id_archivo = l_id_archivo where id_solicitud = i_solicitud and tipo = i_attachment_type;
 else
 insert into snw_fonviv_credito.solicitud_documento (id_solicitud,id_archivo,tipo) values (i_solicitud,l_id_archivo,i_attachment_type);
 end if;
 delete apex_application_temp_files where name = 1;
 end if;
end;