<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterBank extends Model
{
    protected $table='master_banks';

    public $incrementing = false;

    protected $fillable = [
        'id', 'name'
    ];

    // public function user()
    // {
    //     return $this->hasMany('App\User');
    // }
}
