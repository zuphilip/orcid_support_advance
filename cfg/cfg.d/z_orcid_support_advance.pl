###General ORCID Support Advance config###
$c->{orcid_support_advance}->{disable_input} = 1;

$c->{ORCID_contact_email} = $c->{adminemail};

$c->{orcid_support_advance}->{client_id} = "XXXX";
$c->{orcid_support_advance}->{client_secret} = "YYYY";

$c->{orcid_support_advance}->{orcid_apiv2} = "https://api.sandbox.orcid.org/v2.0/";
$c->{orcid_support_advance}->{orcid_org_auth_uri} = "https://sandbox.orcid.org/oauth/authorize";
$c->{orcid_support_advance}->{orcid_org_exch_uri} = "https://api.sandbox.orcid.org/oauth/token";
$c->{orcid_support_advance}->{redirect_uri} = $c->{"perl_url"} . "/orcid/authenticate";

###Enable Screens###
$c->{"plugins"}->{"Screen::AuthenticateOrcid"}->{"params"}->{"disable"} = 0;
$c->{"plugins"}->{"Screen::ManageOrcid"}->{"params"}->{"disable"} = 0;
$c->{"plugins"}->{"Screen::ImportFromOrcid"}->{"params"}->{"disable"} = 0;
$c->{"plugins"}->{"Screen::ExportToOrcid"}->{"params"}->{"disable"} = 0;

###Enable Event Plugins###
$c->{"plugins"}->{"Event::OrcidSync"}->{"params"}->{"disable"} = 0;
$c->{"plugins"}->{"Event::CheckOrcidName"}->{"params"}->{"disable"} = 0;
$c->{"plugins"}->{"Event::UpdateCreatorOrcid"}->{"params"}->{"disable"} = 0;

####Enable Report Plugins###
$c->{plugins}{"Screen::Report::Orcid::CheckName"}{params}{disable} = 0;
$c->{plugin_alias_map}->{"Screen::Report::Orcid::UserOrcid"} = "Screen::Report::Orcid::UserPermsOrcid";
$c->{plugin_alias_map}->{"Screen::Report::Orcid::UserPermsOrcid"} = undef;

###Override DOI Import plugin###
$c->{plugin_alias_map}->{"Import::DOI"} = "Import::OrcidDOI";
$c->{plugin_alias_map}->{"Import::OrcidDOI"} = undef;

#Details of the organization for affiliation inclusion - the easiest way to obtain the RINGGOLD id is to add it to your ORCID user record manually, then pull the orcid-profile via the API and the identifier will be on the record returned.
$c->{"plugins"}->{"Event::OrcidSync"}->{"params"}->{"affiliation"} = {
						"organization" => {
	                                                "name" => "My University Name", #name of organization - REQUIRED
        	                                        "address" => {
                	                                        "city" => "My Town",  # name of the town / city for the organization - REQUIRED if address included
							#	"region" => "Countyshire",  # region e.g. county / state / province - OPTIONAL
							        "country" => "GB",  # 2 letter country code - AU, GB, IE, NZ, US, etc. - REQUIRED if address included
                                        	        },
                                                	"disambiguated-organization" => {
                                                        	"disambiguated-organization-identifier" => "ZZZZ",  # replace ZZZZ with Institutional identifier from the recognised source
	                                                        "disambiguation-source" => "RINGGOLD", # Source for institutional identifier should be RINGGOLD or ISNI
        	                                        }
						}
};

###Education User Types###
##If the user type matches any of the following defined fields, update user's education affiliations rather than employment affiliations
$c->{orcid_support_advance}->{education_user_types} = [];

###User Roles###
push @{$c->{user_roles}->{admin}}, qw{
	+orcid_admin
};

###User fields###
$c->add_dataset_field('user',
        {
                name => 'orcid_access_token',
                type => 'text',
                show_in_html => 0,
                export_as_xml => 0,
                import => 0,
        },
                reuse => 1
);

$c->add_dataset_field('user',
        {
                name => 'orcid_granted_permissions',
                type => 'text',
                show_in_html => 0,
                export_as_xml => 0,
                import => 0,
        },
                reuse => 1
);

$c->add_dataset_field('user',
	{
		name => 'orcid_token_expires',
		type => 'time',
		render_res => 'minute',
		render_style => 'long',
		export_as_xml => 0,
		import => 0,
	},
		reuse => 1
);

$c->add_dataset_field('user',
	{
		name => 'orcid_read_record',
		type => 'boolean',
		show_in_html => 0,
		export_as_xml => 0,
		import => 0,
	},
		reuse => 1
);

$c->add_dataset_field('user',
	{
		name => 'orcid_update_works',
		type => 'boolean',	
		show_in_html => 0,
		export_as_xml => 0,
		import => 0,
	},
		reuse => 1
);

$c->add_dataset_field('user',
	{
		name => 'orcid_update_profile',
		type => 'boolean',	
		show_in_html => 0,
		export_as_xml => 0,
		import => 0,
	},
		reuse => 1
);

$c->add_dataset_field('user',
        {
                name => 'orcid_name',
                type => 'name',
                show_in_html => 0,
                export_as_xml => 0,
                import => 0,
        },
                reuse => 1
);

###EPrint Fields###
$c->add_dataset_field('eprint',
        {
                name => 'orcid_put_codes',
                type => 'text',
                multiple => 1,
                show_in_html => 0,
                export_as_xml => 0,
                import => 0,
        },
                reuse => 1
);

#each permission defined below with some default behaviour (basic permission description commented by each item)
##default - 1 or 0 = this item selected or not selected on screen by default
##display - 1 or 0 = show or show not the option for this item on the screen at all
##admin-edit - 1 or 0 = admins can or can not change this option once users have obtained ORCID authorisation token
##user-edit - 1 or 0 = user can or can not change this option prior to obtaining ORCID authorisation token
##use-value = take the value for this option from the option of another permission e.g. include create if we get update
## **************** AVOID CIRCULAR REFERENCES IN THIS !!!! *******************
## Full Access is granted by the options not commented out below
$c->{ORCID_requestable_permissions} = [
	{
		"permission" => "/authenticate",		#basic link to ORCID ID
		"default" => 1,
		"display" => 1,
		"admin_edit" => 0,
		"user_edit" => 0,
		"use_value" => "self",
		"field" => undef,
	},
	{
		"permission" => "/activities/update",		#update research activities created by this client_id (implies create)
		"default" => 1,
		"display" => 1,
		"admin_edit" => 1,
		"user_edit" => 1,
		"use_value" => "self",
		"field" => "orcid_update_works",
	},
	{
		"permission" => "/read-limited",	#read information from ORCID profile which the user has set to trusted parties only
		"default" => 1,
		"display" => 1,
		"admin_edit" => 1,
		"user_edit" => 1,
		"use_value" => "self",
		"field" => "orcid_read_record",
	},
];

# work types mapping from EPrints to ORCID
# defined separately from the called function to enable easy overriding.
$c->{"plugins"}->{"Screen::ExportToOrcid"}->{"params"}->{"work_type"} = {
		"article" 		=> "JOURNAL_ARTICLE",
		"book_section" 		=> "BOOK_CHAPTER",
		"monograph" 		=> "BOOK",
		"conference_item" 	=> "CONFERENCE_PAPER",
		"book" 			=> "BOOK",
		"thesis" 		=> "DISSERTATION",
		"patent" 		=> "PATENT",
		"artefact" 		=> "OTHER",
		"exhibition" 		=> "OTHER",
		"composition" 		=> "OTHER",
		"performance" 		=> "ARTISTIC_PERFORMANCE",
		"image" 		=> "OTHER",
		"video" 		=> "OTHER",
		"audio" 		=> "OTHER",
		"dataset" 		=> "DATA_SET",
		"experiment" 		=> "OTHER",
		"teaching_resource"	=> "OTHER",
		"other"			=> "OTHER",
};

$c->{"plugins"}->{"Screen::ExportToOrcid"}->{"work_type"} = sub {
#return the ORCID work-type based on the EPrints item type.
##default EPrints item types mapped in $c->{"plugins"}{"Event::OrcidSync"}{"params"}{"work_type"} above.
##ORCID acceptable item types listed here: https://members.orcid.org/api/supported-work-types
##Defined as a function in case there you need to replace it for more complicated processing
##based on other-types or conference_item sub-fields
	my ( $eprint ) = @_;

	my %work_types = %{$c->{"plugins"}{"Screen::ExportToOrcid"}{"params"}{"work_type"}};
	
	if( defined( $eprint ) && $eprint->exists_and_set( "type" ))
	{
		my $ret_val = $work_types{ $eprint->get_value( "type" ) };
		if( defined ( $ret_val ) )
		{
			return $ret_val;
		}
	}
#if no mapping found, call it 'other'
	return "OTHER";
};

$c->{"plugins"}->{"Screen::ImportFromOrcid"}->{"work_type"} = sub {
	my ( $type ) = @_;

	my %work_types = reverse %{$c->{"plugins"}{"Screen::ExportToOrcid"}{"params"}{"work_type"}};
	
	if( defined( $type ) )
	{
		my $ret_val = $work_types{ $type };
		if( defined ( $ret_val ) )
		{
			return $ret_val;
		}
	}
#if no mapping found, call it 'other'
	return "other";
};


# contributor types mapping from EPrints to ORCID - used in Screen::ExportToOrcid to add contributor details to orcid-works and when importing works to eprints
$c->{orcid_support_advance}->{contributor_map} = {
	#eprint field name	=> ORCID contributor type,
	"creators" => "AUTHOR",
	"editors" => "EDITOR",
};

#trigger for acquiring a user's name from their orcid.org profile
$c->add_dataset_trigger( "user", EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub {

        my( %params ) = @_;

        my $repo = $params{repository};
        my $user = $params{dataobj};

	if( $user->is_set( "orcid" ) )
        {
	        $repo->dataset( "event_queue" )->create_dataobj({
        	        pluginid => "Event::CheckOrcidName",
                	action => "check_name",
	                params => ["/id/user/".$user->get_value( "userid" )],
        	});
	}
} );

###
# These triggers have been commented out as they have the potential to wipe creator/editor ORCID data. 
# However they are necessary when the ORCID field is non-editable to ensure that ORCIDs are only ever authenticated against user profiles.
# Re-enable only if repository user profiles (connected to orcid.org) are the sole source of ORCID data.
###
#automatic update of eprint creator field - orcid must be set to user's orcid value
#$c->add_dataset_trigger( 'eprint', EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub
#{
#        my( %args ) = @_;
#        my( $repo, $eprint, $changed ) = @args{qw( repository dataobj changed )};
#	
#        return unless $eprint->dataset->has_field( "creators_orcid" );
#
#        my $creators = $eprint->get_value('creators');
#        my @new_creators;
#
#        foreach my $c (@{$creators})
#        {
#                my $new_c = $c;
#                #get id and user profile
#                my $email = $c->{id};
#                $email = lc($email) if defined $email;
#                my $user = EPrints::DataObj::User::user_with_email($eprint->repository, $email);
#                if( $user )
#                {
#                        if( EPrints::Utils::is_set( $user->value( 'orcid' ) ) ) #user has an orcid
#                        {
#				#set the orcid
#                                $new_c->{orcid} = $user->value( 'orcid' );
#                                
#                        }
#			else
#			{
#				$new_c->{orcid} = undef;
#			}
#                }
#                push( @new_creators, $new_c );
#        }
#        $eprint->set_value("creators", \@new_creators);
#}, priority => 60 );

#automatic update of eprint editor field - orcid must be set to user's orcid value
#$c->add_dataset_trigger( 'eprint', EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub
#{
#        my( %args ) = @_;
#        my( $repo, $eprint, $changed ) = @args{qw( repository dataobj changed )};
#
#        return unless $eprint->dataset->has_field( "editors_orcid" );
#
#        my $editors = $eprint->get_value('editors');
#        my @new_editors;
#
#        foreach my $e (@{$editors})
#        {
#                my $new_e = $e;
#                #get id and user profile
#                my $email = $e->{id};
#                $email = lc($email) if defined $email;
#                my $user = EPrints::DataObj::User::user_with_email($eprint->repository, $email);
#                if( $user )
#                {
#                        if( EPrints::Utils::is_set( $user->value( 'orcid' ) ) ) #user has an orcid
#                        {
#                                #set the orcid
#                                $new_e->{orcid} = $user->value( 'orcid' );
#                        }
#                        else
#                        {
#                                $new_e->{orcid} = undef;
#                        }
#                }
#                push( @new_editors, $new_e );
#        }
#        $eprint->set_value("editors", \@new_editors);
#}, priority => 60 );
