<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterBranch extends Model
{
    protected $table='master_branches';
    public $incrementing = false;

    protected $fillable = [
        'id', 'name','bank_id','is_kp'
    ];

    function bank() {
        return $this->belongsTo('App\Models\MasterBank');
    }

}
