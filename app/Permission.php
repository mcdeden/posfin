<?php

namespace App;

use Laratrust\Models\LaratrustPermission;

class Permission extends LaratrustPermission
{
    protected $table='permissions';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'name','display_name'
    ];
}
