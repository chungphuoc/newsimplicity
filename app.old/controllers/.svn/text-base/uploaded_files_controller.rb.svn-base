class UploadedFilesController < ApplicationController
    def get_file
        #TODO security stuff
        begin
            file = UploadedFile.find(params[:id]);
            if ( file.nil? )
                raise "FILE NOT FOUND"
            end
            # TODO make sure the current user can access this file. Also in other places for this.
            send_data ( file.data,
                        :filename => file.name,
                        :type => file.mime_type,
                        :disposition => "attachment" );
#        rescue RecordNotFound=>e
#            add_error "FILE NOT FOUND";
#            redirect_to( HashMarshaler.unmarshal_hash(params[:origin]) );
# TODO make this work
        rescue Exception=>e
            add_error e.message;
            redirect_to( HashMarshaler.unmarshal_hash(params[:origin]) ); 
        end
    end
end
