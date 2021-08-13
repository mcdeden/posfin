<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterDataStatus extends Model
{
    protected $table='master_data_status';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'name'
    ];
}
