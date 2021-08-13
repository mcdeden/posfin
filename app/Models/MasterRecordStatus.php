<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterRecordStatus extends Model
{
    protected $table='master_record_status';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'name'
    ];
}
