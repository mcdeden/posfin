<?php

namespace App;

use Laratrust\Models\LaratrustRole;

class Role extends LaratrustRole
{
    protected $table='roles';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'name','display_name'
    ];
}
