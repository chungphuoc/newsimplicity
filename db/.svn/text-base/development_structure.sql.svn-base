CREATE TABLE `advertisements` (
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `body` text,
  `published_on` datetime default NULL,
  `display_on_site` tinyint(1) default NULL,
  `link` varchar(255) default NULL,
  `file` varchar(255) default NULL,
  `file_suffix` varchar(255) default NULL,
  `building_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `building_owners` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) default NULL,
  `hashed_password` varchar(255) default NULL,
  `salt` varchar(255) default NULL,
  `first_name` varchar(255) default NULL,
  `surname` varchar(255) default NULL,
  `mobile` varchar(255) default NULL,
  `phone` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `fax` varchar(255) default NULL,
  `address` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `building_units` (
  `id` int(11) NOT NULL auto_increment,
  `building_id` int(11) default NULL,
  `unit_type_id` int(11) default NULL,
  `area` int(11) default NULL,
  `unit_count` int(11) default '1',
  `floor` int(11) default NULL,
  `name` varchar(255) default NULL,
  `remarks` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `building_units_unit_contracts` (
  `building_unit_id` int(11) default NULL,
  `unit_contract_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `buildings` (
  `id` int(11) NOT NULL auto_increment,
  `number` varchar(255) default NULL,
  `street` varchar(255) default NULL,
  `city` varchar(255) default NULL,
  `zip_code` varchar(5) default NULL,
  `welcome_note` text,
  `directions` text,
  `eng_city` varchar(255) default NULL,
  `eng_street` varchar(255) default NULL,
  `eng_number` varchar(255) default NULL,
  `print_map_extension` varchar(50) default NULL,
  `map_extension` varchar(50) default NULL,
  `lowest_floor` int(11) default NULL,
  `highest_floor` int(11) default NULL,
  `mt_company_id` int(11) default NULL,
  `mt_building_manager_id` int(11) default NULL,
  `mt_company_contact_id` int(11) default NULL,
  `disable_checks` tinyint(1) default '0',
  `type` varchar(255) default 'Building',
  `building_owner_id` int(11) default NULL,
  `total_area` int(11) default NULL,
  `total_unit_num` int(11) default NULL,
  `forum_url` varchar(255) default NULL,
  `is_user_login_unique` tinyint(1) default '0',
  `show_whose_car` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 PACK_KEYS=1;

CREATE TABLE `business_buildings_businesses` (
  `id` int(11) NOT NULL auto_increment,
  `business_building_id` int(11) default NULL,
  `business_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `businesses` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `eng_name` varchar(255) default NULL,
  `description` text,
  `site` varchar(255) default NULL,
  `phone` varchar(255) default NULL,
  `fax` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `building_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cars` (
  `id` int(11) NOT NULL auto_increment,
  `number` varchar(255) default NULL,
  `description` text,
  `tenant_id` int(11) default NULL,
  `business_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `condo_questions` (
  `id` int(11) NOT NULL auto_increment,
  `question` varchar(255) default NULL,
  `answer` text,
  `link` varchar(255) default NULL,
  `display_on_site` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `contact_people` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) default NULL,
  `surname` varchar(255) default NULL,
  `company` varchar(255) default NULL,
  `phone` varchar(255) default NULL,
  `fax` varchar(255) default NULL,
  `mobile` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `site` varchar(255) default NULL,
  `about` text,
  `address` varchar(255) default NULL,
  `cp_category_id` int(11) NOT NULL default '0',
  `position` varchar(255) default NULL,
  `building_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_contact_people_cp_categories` (`cp_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cp_categories` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `building_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `flats` (
  `id` int(11) NOT NULL auto_increment,
  `number` int(11) default NULL,
  `floor` int(11) default NULL,
  `state` varchar(21) default NULL,
  `area` int(11) default NULL,
  `base_payment` decimal(10,0) default '0',
  `num_of_rooms` float default NULL,
  `building_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `localized_entries` (
  `entry` varchar(255) default NULL,
  `value` varchar(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `maintenance_request_history_items` (
  `id` int(11) NOT NULL auto_increment,
  `action_type` varchar(16) default NULL,
  `acting_user_data` varchar(255) default NULL,
  `acting_user_id` int(11) default NULL,
  `acting_user_type` varchar(255) default NULL,
  `maintenance_request_id` int(11) default NULL,
  `remarks` text,
  `new_state_data` varchar(255) default NULL,
  `created_on` datetime default NULL,
  `old_state_data` varchar(255) default NULL,
  `company_private` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `maintenance_requests` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `body` text,
  `created_on` datetime default NULL,
  `updated_on` datetime default NULL,
  `urgency` int(11) default '2',
  `building_id` int(11) default NULL,
  `state` int(11) default '0',
  `solving_worker_id` int(11) default NULL,
  `remarks` text,
  `reporter_id` int(11) default NULL,
  `reporter_type` varchar(255) default NULL,
  `place_id` int(11) default NULL,
  `place_type` varchar(255) default NULL,
  `business_id` int(11) default NULL,
  `flat_id` int(11) default NULL,
  `accepted` tinyint(1) default '0',
  `hours_of_fix` float default NULL,
  `parts_cost_of_fix` float default NULL,
  `fixed_price_of_fix` float default NULL,
  `price_per_hour` float default NULL,
  `solved_on` datetime default NULL,
  `assignee_id` int(11) default NULL,
  `assignee_type` varchar(255) default NULL,
  `quoted_price` float default NULL,
  `service_type` int(11) default '0',
  `place_free_text` varchar(255) default NULL,
  `budget_id` int(11) default NULL,
  `qoute_text` text,
  `mt_company_task_id` int(11) default NULL,
  `mt_company_id` int(11) default NULL,
  `budget_name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mt_companies` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `eng_name` varchar(255) default NULL,
  `address` text,
  `contact_info` text,
  `site` varchar(255) default NULL,
  `phone` varchar(255) default NULL,
  `about` text,
  `image_extension` varchar(255) default NULL,
  `disable_checks` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mt_company_tasks` (
  `id` int(11) NOT NULL auto_increment,
  `from_date` date default NULL,
  `until_date` date default NULL,
  `status` int(11) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `created_on` datetime default NULL,
  `completed_on` datetime default NULL,
  `building_id` int(11) default NULL,
  `mt_company_id` int(11) default NULL,
  `building_owner_id` int(11) default NULL,
  `assignee_id` int(11) default NULL,
  `assignee_type` varchar(255) default NULL,
  `creator_id` int(11) default NULL,
  `creator_type` varchar(255) default NULL,
  `maintenance_request_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mt_company_worker_roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `building_manager` tinyint(1) default NULL,
  `admin` tinyint(1) default NULL,
  `mt_company_id` int(11) default NULL,
  `professional` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mt_company_workers` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) default NULL,
  `surname` varchar(255) default NULL,
  `mobile` varchar(255) default NULL,
  `beeper` varchar(255) default NULL,
  `username` varchar(255) default NULL,
  `hashed_password` varchar(255) default NULL,
  `salt` varchar(255) default NULL,
  `mt_company_role_id` int(11) default NULL,
  `mt_company_id` int(11) default NULL,
  `email` varchar(255) default NULL,
  `details` text,
  `sms_urgency` int(11) default '5',
  `group_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `place_list_items` (
  `id` int(11) NOT NULL auto_increment,
  `place` varchar(255) default NULL,
  `is_my_flat` tinyint(1) default NULL,
  `floor_relative` tinyint(1) default NULL,
  `building_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `sessions_session_id_index` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `shared_documents` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `description` text,
  `file_suffix` varchar(255) default NULL,
  `updated_on` datetime default NULL,
  `building_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `suggestions` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `body` text,
  `created_on` date default NULL,
  `ctrl` varchar(255) default NULL,
  `actn` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `super_users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) default NULL,
  `hashed_password` varchar(255) default NULL,
  `salt` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tenant_posts` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `body` text,
  `published_on` datetime default NULL,
  `display_on_site` tinyint(1) default NULL,
  `link` varchar(255) default NULL,
  `file` varchar(255) default NULL,
  `tenant_id` varchar(255) default NULL,
  `file_suffix` varchar(255) default NULL,
  `building_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tenants` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) default NULL,
  `surname` varchar(255) default NULL,
  `phone` varchar(255) default NULL,
  `fax` varchar(255) default NULL,
  `mobile` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `site` varchar(255) default NULL,
  `about` text,
  `flat_id` int(11) default NULL,
  `is_male` tinyint(1) default NULL,
  `username` varchar(255) default NULL,
  `hashed_password` varchar(255) default NULL,
  `salt` varchar(255) default NULL,
  `role` varchar(255) default NULL,
  `building_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_tenants_flats` (`flat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `unit_contracts` (
  `id` int(11) NOT NULL auto_increment,
  `business_id` int(11) default NULL,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `mode` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `unit_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `building_owner_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `uploaded_files` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `size` int(11) default NULL,
  `upload_date` datetime default NULL,
  `mime_type` varchar(255) default NULL,
  `uploader_id` int(11) default NULL,
  `uploader_type` varchar(255) default NULL,
  `part_of_id` int(11) default NULL,
  `part_of_type` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) default NULL,
  `hashed_password` varchar(255) default NULL,
  `salt` varchar(255) default NULL,
  `description` text,
  `user_type` varchar(255) default NULL,
  `first_name` varchar(255) default NULL,
  `surname` varchar(255) default NULL,
  `contact_info` varchar(255) default NULL,
  `building_id` int(11) default NULL,
  `business_id` int(11) default NULL,
  `mobile` varchar(255) default NULL,
  `phone` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `address` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_info (version) VALUES (72)